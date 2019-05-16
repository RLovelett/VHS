//
//  VCRSequenceTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 12/02/2016.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation
@testable import VHS
import XCTest

final class EphemeralSequenceTests: XCTestCase {

    lazy var multipleTracks: [Track]! = {
        let vinyl = try? Cassette(fixtureWithName: "vinyl_multiple")
        return vinyl?.tracks
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.continueAfterFailure = false
        XCTAssertNotNil(self.multipleTracks)
        self.continueAfterFailure = true
    }

    func testOrderedSequence() {
        let request = MockRequest(url: URL(string: "http://api.test2.com")!)
        var sequence = EphemeralSequence(sequenceOf: self.multipleTracks, inOrder: .cassetteOrder)

        // ✅ Test to make sure the sequence plays exactly in the order of the fixture
        // (e.g., ignore matching)
        let firstTrack = sequence.next(for: request)
        XCTAssertNotNil(firstTrack)
        XCTAssertEqual(firstTrack?.request.url, URL(string: "http://api.test1.com"))

        let secondTrack = sequence.next(for: request)
        XCTAssertNotNil(secondTrack)
        XCTAssertEqual(secondTrack?.request.url, URL(string: "http://api.test2.com"))

        // ✅ Test to make sure the sequence ends at the appropriate time (e.g., after two requests)
        XCTAssertNil(sequence.next(for: request))
    }

    func testMatchingSequence() {
        let match = VCR.PlaybackSequence.properties(matching: [.url])
        var sequence = EphemeralSequence(sequenceOf: self.multipleTracks, inOrder: match)

        // ✅ Test to make sure the sequence plays out of order (because matching is applied)
        let firstURL = URL(string: "http://api.test2.com")!
        let firstRequest = MockRequest(url: firstURL)
        let firstTrack = sequence.next(for: firstRequest)
        XCTAssertNotNil(firstTrack)
        XCTAssertEqual(firstTrack?.request.url, firstURL)

        let secondURL = URL(string: "http://api.test1.com")!
        let secondRequest = MockRequest(url: secondURL)
        let secondTrack = sequence.next(for: secondRequest)
        XCTAssertNotNil(secondTrack)
        XCTAssertEqual(secondTrack?.request.url, secondURL)

        // ✅ Test to make sure the sequence ends at the appropriate time (e.g., after two requests)
        XCTAssertNil(sequence.next(for: firstRequest))
        XCTAssertNil(sequence.next(for: secondRequest))
    }

    func testMatchingSequenceWithMultipleDimensions() {
        let match = VCR.PlaybackSequence.properties(matching: [.path, .method])
        var sequence = EphemeralSequence(sequenceOf: self.multipleTracks, inOrder: match)

        let firstURL = URL(string: "http://api.test1.com")!
        let firstRequest = MockRequest(url: firstURL, method: .head)
        let firstTrack = sequence.next(for: firstRequest)
        XCTAssertNil(firstTrack)

        let secondRequest = MockRequest(url: firstURL)
        let secondTrack = sequence.next(for: secondRequest)
        XCTAssertNotNil(secondTrack)
    }

}

final class LoopingSequenceTests: XCTestCase {

    lazy var multipleTracks: [Track]! = {
        let vinyl = try? Cassette(fixtureWithName: "vinyl_multiple")
        return vinyl?.tracks
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.continueAfterFailure = false
        XCTAssertNotNil(self.multipleTracks)
        self.continueAfterFailure = true
    }

    func testOrderedSequence() {
        let request = MockRequest(url: URL(string: "http://api.test2.com")!)
        var sequence = LoopingSequence(sequenceOf: self.multipleTracks, inOrder: .cassetteOrder)

        // ✅ Test to make sure the sequence plays exactly in the order of the fixture
        // (e.g., ignore matching)
        let firstTrack = sequence.next(for: request)
        XCTAssertNotNil(firstTrack)
        XCTAssertEqual(firstTrack?.request.url, URL(string: "http://api.test1.com"))

        let secondTrack = sequence.next(for: request)
        XCTAssertNotNil(secondTrack)
        XCTAssertEqual(secondTrack?.request.url, URL(string: "http://api.test2.com"))

        // ✅ Test to make sure the sequence loops back to the start after two requests
        let thirdTrack = sequence.next(for: request)
        XCTAssertNotNil(thirdTrack)
        XCTAssertEqual(thirdTrack?.request.url, URL(string: "http://api.test1.com"))

        let fourthTrack = sequence.next(for: request)
        XCTAssertNotNil(fourthTrack)
        XCTAssertEqual(fourthTrack?.request.url, URL(string: "http://api.test2.com"))
    }

    func testMatchingSequence() {
        let match = VCR.PlaybackSequence.properties(matching: [.url])
        var sequence = LoopingSequence(sequenceOf: self.multipleTracks, inOrder: match)

        // ✅ Test to make sure the sequence plays out of order (because matching is applied)
        let firstURL = URL(string: "http://api.test2.com")!
        let firstRequest = MockRequest(url: firstURL)
        let firstTrack = sequence.next(for: firstRequest)
        XCTAssertNotNil(firstTrack)
        XCTAssertEqual(firstTrack?.request.url, firstURL)

        let secondURL = URL(string: "http://api.test1.com")!
        let secondRequest = MockRequest(url: secondURL)
        let secondTrack = sequence.next(for: secondRequest)
        XCTAssertNotNil(secondTrack)
        XCTAssertEqual(secondTrack?.request.url, secondURL)

        // ✅ Test to make sure the sequence does not stop matching
        let thirdTrack = sequence.next(for: firstRequest)
        XCTAssertNotNil(thirdTrack)
        XCTAssertEqual(thirdTrack?.request.url, firstURL)

        let fourthTrack = sequence.next(for: secondRequest)
        XCTAssertNotNil(fourthTrack)
        XCTAssertEqual(fourthTrack?.request.url, secondURL)

        // ✅ Test that unmatched still fail
        let unmatchedURL = URL(string: "http://www.google.com")!
        let unmatchedRequest = MockRequest(url: unmatchedURL)
        let unmatchedTrack = sequence.next(for: unmatchedRequest)
        XCTAssertNil(unmatchedTrack)
    }

}
