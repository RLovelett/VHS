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
private let trackRequest = Track.Request(url: url, method: .head, headers: reqHeader, body: json)
private let resHeader = ["ETag": "686897696a7c876b7e"]
private let trackResponse = Track.Response(url: url, statusCode: 200, headers: reqHeader, error: nil, body: nil)
private let track = Track(request: trackRequest, response: trackResponse)

// MARK: - Test matching by HTTP method (or verb)

final class PlaybackSequenceMatchTypeMethodTests: XCTestCase {

    var request: URLRequest!

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.request = URLRequest(url: url)
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
        self.request.url = mismatchURL
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
        self.components = URLComponents(url: mismatchURL, resolvingAgainstBaseURL: false)
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
        self.components = URLComponents(url: mismatchURL, resolvingAgainstBaseURL: false)
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
        self.request = URLRequest(url: mismatchURL)
        self.request.allHTTPHeaderFields = trackRequest.headers
    }

    func testMatchingHeaders() {
        XCTAssertTrue(self.matcher.match(track, with: self.request))
    }

    func testRequestWithoutHeaders() {
        let trackRequest = Track.Request(url: url, method: .head, headers: nil, body: json)
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
        self.request = URLRequest(url: mismatchURL)
        self.request.httpBody = Data(base64Encoded: "8J+RiyBteSBuYW1lIGlzIFJ5YW4=")
    }

    func testMatchingBody() {
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.body.match(track, with: self.request))
    }

    func testRequestWithoutBody() {
        let trackRequest = Track.Request(url: url, method: .head, headers: reqHeader, body: nil)
        let track = Track(request: trackRequest, response: trackResponse)
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.body.match(track, with: self.request))
    }

    func testDifferentBody() {
        self.request.httpBody = Data(base64Encoded: "SGkgbXkgbmFtZSBpcyBSeWFu")
        XCTAssertFalse(VCR.PlaybackSequence.MatchType.body.match(track, with: self.request))
    }

    func testBothBodyAreNil() {
        // Make the track have a nil body
        let nilBodyRequest = Track.Request(url: url, method: .head, headers: reqHeader, body: nil)
        let track = Track(request: nilBodyRequest, response: trackResponse)

        // Make the request have a nil body
        self.request.httpBody = nil

        // Expect them to match
        XCTAssertTrue(VCR.PlaybackSequence.MatchType.body.match(track, with: self.request))
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
        self.request = URLRequest(url: mismatchURL)
    }

    func testMatchingCustomFunction() {
        let matcher = VCR.PlaybackSequence.MatchType.custom(using: customMatching)
        XCTAssertTrue(matcher.match(track, with: self.request))
    }

}
