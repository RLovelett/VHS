//
//  TrackRequestTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 6/25/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

final class TrackRequestTests: XCTestCase {

    // MARK: - JSON that does not create a valid Request

    func testInvalidRequestEmptyJSONObject() {
        let json = Data(fixtureWithName: "request_empty")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Request.self, from: json),
                             "A Track with an empty Request should fail.")
    }

    func testInvalidRequestWithoutURL() {
        let json = Data(fixtureWithName: "request_without_url")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Request.self, from: json),
                             "A Track without a request URL should fail.")
    }

    func testInvalidRequestWithMalformedURL() {
        let json = Data(fixtureWithName: "request_with_malformed_url")
        XCTAssertThrowsError( try JSONDecoder().decode(Track.Request.self, from: json),
                              "A Track with a malformed request URL should fail.")
    }

    func testInvalidRequestWithMalformedURLAsObject() {
        let json = Data(fixtureWithName: "request_with_malformed_url_as_object")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Request.self, from: json),
                             "A Track with a malformed request URL should fail.")
    }

    func testInvalidRequestHeaderJSONPropertyIsString() {
        let json = Data(fixtureWithName: "request_with_malformed_headers")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Request.self, from: json),
                             "A Track whose header is not a JSON object should fail.")
    }

    func testInvalidRequestHeaderJSONObjectHasInteger() {
        let json = Data(fixtureWithName: "request_with_malformed_header_integer")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Request.self, from: json),
                             "A Track whose header is not a JSON object should fail.")
    }

    // MARK: - JSON that does create a valid Request

    func testValidRequestWithoutMethod() {
        let json = Data(fixtureWithName: "request_without_method")
        let request = XCTAssertNoThrowAndReturn(try JSONDecoder().decode(Track.Request.self, from: json))
        XCTAssertEqual(request?.method, .get)
        XCTAssertEqual(request?.url, URL(string: "http://opera.com/faucibus/orci/luctus.xml"))
        XCTAssertNil(request?.body)
    }

    func testValidRequestWithURLAndGetMethod() {
        let json = Data(fixtureWithName: "request_with_url_and_get")
        let request = XCTAssertNoThrowAndReturn(try JSONDecoder().decode(Track.Request.self, from: json))
        XCTAssertEqual(request?.method, .get)
        XCTAssertEqual(request?.url, URL(string: "http://opera.com/faucibus/orci/luctus.xml"))
        XCTAssertNil(request?.body)
    }

    func testValidRequestWithTextBody() {
        let json = Data(fixtureWithName: "request_with_text_body")
        let request = XCTAssertNoThrowAndReturn(try JSONDecoder().decode(Track.Request.self, from: json))
        XCTAssertEqual(request?.method, .post)
        XCTAssertEqual(request?.url, URL(string: "http://api.test.com"))
        XCTAssertEqual(request?.body?.string, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
    }

    func testValidRequestWithBase64EncodedText() {
        let json = Data(fixtureWithName: "request_with_base64_body")
        let request = XCTAssertNoThrowAndReturn(try JSONDecoder().decode(Track.Request.self, from: json))
        XCTAssertEqual(request?.method, .post)
        XCTAssertEqual(request?.url, URL(string: "http://api.test.com"))
        XCTAssertEqual(request?.body?.string, "{\"username\":\"ziggy\",\"password\":\"stardust\"}")
        XCTAssertEqual(request?.body?.base64, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
    }

    func testValidRequestWithJSONBody() {
        let json = Data(fixtureWithName: "request_with_json_body")
        let request = XCTAssertNoThrowAndReturn(try JSONDecoder().decode(Track.Request.self, from: json))
        XCTAssertEqual(request?.method, .post)
        XCTAssertEqual(request?.url, URL(string: "http://api.test.com"))
        XCTAssertEqual(request?.body?.base64, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
    }

}
