//
//  PlaybackSequenceMatchTypeTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/17/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

private let url = URL(string: "http://api.test2.com/this/is/a/path?one=two&three=4")!
private let baseComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
private let mismatchURL = URL(string: "https://api.test.com")!

// "8J+RiyBteSBuYW1lIGlzIFJ5YW4=" -> "👋 my name is Ryan"
private let json = Body(MockBody("👋 my name is Ryan"))
private let reqHeader = ["username": "cool"]
private let trackRequest = MockRequest(url: url, method: .head, headers: reqHeader, body: json)

// MARK: - Test matching by HTTP method (or verb)

final class PlaybackSequenceMatchTypeMethodTests: XCTestCase {

    let uut = VCR.PlaybackSequence.MatchType.method

    func testSameMethod() {
        let request = MockRequest(url: url, method: .head)
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testDifferentMethod() {
        let request = MockRequest(url: url, method: .get)
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

}

// MARK: - Test matching by requested URL

final class PlaybackSequenceMatchTypeURLTests: XCTestCase {

    let uut = VCR.PlaybackSequence.MatchType.url

    func testExactMatch() {
        let request = MockRequest(url: url, method: .get)
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testPurposelyMismatched() {
        let request = MockRequest(url: mismatchURL, method: .get)
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

}

// MARK: - Test matching using just the path of the requested URL

final class PlaybackSequenceMatchTypePathTests: XCTestCase {

    let uut = VCR.PlaybackSequence.MatchType.path

    var components: URLComponents!

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.components = URLComponents(url: mismatchURL, resolvingAgainstBaseURL: false)
        self.components.path = baseComponents.path
    }

    func testMatchingPath() {
        let request = self.components.url.map({ MockRequest(url: $0) })!
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testDifferentHostname() {
        self.components.host = "api.test.com"
        let request = self.components.url.map({ MockRequest(url: $0) })!
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testDifferentQuery() {
        self.components?.queryItems = [ URLQueryItem(name: "two", value: "two") ]
        let request = self.components.url.map({ MockRequest(url: $0) })!
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testDifferentPath() {
        self.components?.path = "/now/this/is/a/path"
        let request = self.components.url.map({ MockRequest(url: $0) })!
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

}

// MARK: - Test matching using just the query of the requested URL

final class PlaybackSequenceMatchTypeQueryTests: XCTestCase {

    let uut = VCR.PlaybackSequence.MatchType.query

    var components: URLComponents!

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.components = URLComponents(url: mismatchURL, resolvingAgainstBaseURL: false)
        self.components.queryItems = baseComponents.queryItems
    }

    func testMatchingQuery() {
        let request = self.components.url.map({ MockRequest(url: $0) })!
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testQueryElementOrder() {
        self.components.queryItems = self.components.queryItems?.reversed()
        let request = self.components.url.map({ MockRequest(url: $0) })!
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testRequestWithoutQueries() {
        self.components.queryItems = .none
        let request = self.components.url.map({ MockRequest(url: $0) })!
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

    func testDifferentQueries() {
        self.components.queryItems = [ URLQueryItem(name: "two", value: "two") ]
        let request = self.components.url.map({ MockRequest(url: $0) })!
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

}

// MARK: - Test matching using just the headers sent with the request

final class PlaybackSequenceMatchTypeHeaderTests: XCTestCase {

    let uut = VCR.PlaybackSequence.MatchType.headers

    func testMatchingHeaders() {
        let request = MockRequest(url: mismatchURL, headers: trackRequest.headers)
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testRequestWithoutHeaders() {
        let request = MockRequest(url: mismatchURL, headers: trackRequest.headers)
        let trackRequest = MockRequest(url: url, method: .head, headers: nil, body: json)
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

    func testDifferentHeaders() {
        let request = MockRequest(url: mismatchURL, headers: [ "username": "Cool" ])
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

}

// MARK: - Test matching using just the body sent with the request

final class PlaybackSequenceMatchTypeBodyTests: XCTestCase {

    let uut = VCR.PlaybackSequence.MatchType.body

    func testMatchingBody() {
        let request = MockRequest(url: mismatchURL, base64: "8J+RiyBteSBuYW1lIGlzIFJ5YW4=")
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

    func testRequestWithoutBody() {
        let request = MockRequest(url: mismatchURL, base64: "8J+RiyBteSBuYW1lIGlzIFJ5YW4=")
        let trackRequest = MockRequest(url: url, method: .head, headers: reqHeader, body: nil)
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

    func testDifferentBody() {
        let request = MockRequest(url: mismatchURL, base64: "SGkgbXkgbmFtZSBpcyBSeWFu")
        XCTAssertFalse(uut.match(trackRequest, with: request))
    }

    func testBothBodyAreNil() {
        // Make the track have a nil body
        let nilBodyRequest = MockRequest(url: url, method: .head, headers: reqHeader, body: nil)

        // Make the request have a nil body
        let request = MockRequest(url: mismatchURL)

        // Expect them to match
        XCTAssertTrue(uut.match(nilBodyRequest, with: request))
    }

}

// MARK: - Test matching using a custom function

final class PlaybackSequenceMatchTypeCustomTests: XCTestCase {

    let customMatching: (Request, Request) -> Bool = { (track, _) -> Bool in
        return track.method == .head && track.url.path == "/this/is/a/path"
    }

    func testMatchingCustomFunction() {
        let request = MockRequest(url: mismatchURL)
        let uut = VCR.PlaybackSequence.MatchType.custom(using: customMatching)
        XCTAssertTrue(uut.match(trackRequest, with: request))
    }

}
