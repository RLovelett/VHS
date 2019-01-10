//
//  PlaybackSequenceMatchTypeTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/17/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
@testable import VHS
import XCTest

private let url = URL(string: "http://api.test2.com/this/is/a/path?one=two&three=4")!
private let baseComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!

// "8J+RiyBteSBuYW1lIGlzIFJ5YW4=" -> "👋 my name is Ryan"
private let json = JSON.string("8J+RiyBteSBuYW1lIGlzIFJ5YW4=")
private let reqHeader = ["username": "cool"]
private let trackRequest = Track.Request(from: url, using: .head, with: reqHeader, sending: json)
private let resHeader = ["ETag": "686897696a7c876b7e"]
private let trackResponse = Track.Response(from: url, providing: 200, with: resHeader, sending: nil)
private let track = Track(request: trackRequest, response: trackResponse)

// MARK: - Test matching by HTTP method (or verb)

final class PlaybackSequenceMatchTypeMethodTests: XCTestCase {

    var request: URLRequest!

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.request = URLRequest(url: URL.arbitrary.generate)
        self.request.httpMethod = "Head"
    }

    func testSameMethod() {
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.method.match(track, with: self.request))
    }

    func testDifferentMethod() {
        self.request.httpMethod = "GET"
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.method.match(track, with: self.request))
    }

}

// MARK: - Test matching by requested URL

final class PlaybackSequenceMatchTypeURLTests: XCTestCase {

    var request: URLRequest!

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.request = URLRequest(url: url)
    }

    func testExactMatch() {
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.url.match(track, with: self.request))
    }

    func testPurposelyMismatched() {
        self.request.url = URLComponents.arbitrary.generate.url
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.url.match(track, with: self.request))
    }

}

// MARK: - Test matching using just the path of the requested URL

final class PlaybackSequenceMatchTypePathTests: XCTestCase {

    var request: URLRequest!

    var components: URLComponents!

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.components = URLComponents.arbitrary.generate
        self.components.path = baseComponents.path
        self.request = self.components.url.flatMap({ URLRequest(url: $0) })
    }

    func testMatchingPath() {
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.path.match(track, with: self.request))
    }

    func testDifferentHostname() {
        self.components.host = "api.test.com"
        self.request.url = self.components?.url
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.path.match(track, with: self.request))
    }

    func testDifferentQuery() {
        self.components?.queryItems = [ URLQueryItem(name: "two", value: "two") ]
        self.request.url = self.components?.url
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.path.match(track, with: self.request))
    }

    func testDifferentPath() {
        self.components?.path = "/now/this/is/a/path"
        self.request.url = self.components.url
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.path.match(track, with: self.request))
    }

}

// MARK: - Test matching using just the query of the requested URL

final class PlaybackSequenceMatchTypeQueryTests: XCTestCase {

    var request: URLRequest!

    var components: URLComponents!

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.components = URLComponents.arbitrary.generate
        self.components.queryItems = baseComponents.queryItems
        self.request = self.components.url.flatMap({ URLRequest(url: $0) })
    }

    func testMatchingQuery() {
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.query.match(track, with: self.request))
    }

    func testQueryElementOrder() {
        self.components.queryItems = self.components.queryItems?.reversed()
        self.request.url = self.components.url
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.query.match(track, with: self.request))
    }

    func testRequestWithoutQueries() {
        self.components.queryItems = .none
        self.request.url = self.components.url
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.query.match(track, with: self.request))
    }

    func testDifferentQueries() {
        self.components.queryItems = [ URLQueryItem(name: "two", value: "two") ]
        self.request.url = self.components.url
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.query.match(track, with: self.request))
    }

}

// MARK: - Test matching using just the headers sent with the request

final class PlaybackSequenceMatchTypeHeaderTests: XCTestCase {

    var request: URLRequest!

    let matcher = VCR.PlaybackSequence.MatchType.headers

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.request = URLRequest(url: URL.arbitrary.generate)
        self.request.allHTTPHeaderFields = trackRequest.headers
    }

    func testMatchingHeaders() {
        XCTAssertTrue(self.matcher.match(track, with: self.request))
    }

    func testRequestWithoutHeaders() {
        let trackRequest = Track.Request(from: url, using: .head, with: .none, sending: json)
        let track = Track(request: trackRequest, response: trackResponse)
        XCTAssertFalse(self.matcher.match(track, with: self.request))
    }

    func testDifferentHeaders() {
        self.request.allHTTPHeaderFields = [ "username": "Cool" ]
        XCTAssertFalse(self.matcher.match(track, with: self.request))
    }

}

// MARK: - Test matching using just the body sent with the request

final class PlaybackSequenceMatchTypeBodyTests: XCTestCase {

    var request: URLRequest!

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.request = URLRequest(url: URL.arbitrary.generate)
        self.request.httpBody = Data(base64Encoded: "8J+RiyBteSBuYW1lIGlzIFJ5YW4=")
    }

    func testMatchingBody() {
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.body.match(track, with: self.request))
    }

    func testRequestWithoutBody() {
        let trackRequest = Track.Request(from: url, using: .head, with: reqHeader, sending: nil)
        let track = Track(request: trackRequest, response: trackResponse)
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.body.match(track, with: self.request))
    }

    func testDifferentBody() {
        self.request.httpBody = Data(base64Encoded: "SGkgbXkgbmFtZSBpcyBSeWFu")
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.body.match(track, with: self.request))
    }

}

// MARK: - Test matching using a custom function

final class PlaybackSequenceMatchTypeCustomTests: XCTestCase {

    var request: URLRequest!

    let customMatching: (Track, URLRequest) -> Bool = { (track, _) -> Bool in
        return track.request.method == .head && track.request.url.path == "/this/is/a/path"
    }

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.request = URLRequest(url: URL.arbitrary.generate)
    }

    func testMatchingCustomFunction() {
        let matcher = VCR.PlaybackSequence.MatchType.custom(using: customMatching)
        XCTAssertTrue(matcher.match(track, with: self.request))
    }

}
