//
//  TrackResponseTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/14/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

final class TrackResponseTests: XCTestCase {

    // MARK: - JSON that does not create a valid Response

    func testInvalidResponseEmptyJSONObject() {
        let json = Data(fixtureWithName: "request_empty")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Response.self, from: json),
                             "A Track with an empty Request should fail.")
    }

    func testInvalidRequestWithoutURL() {
        let json = Data(fixtureWithName: "request_without_url")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Response.self, from: json),
                             "A Track without a request URL should fail.")
    }

    func testInvalidRequestWithMalformedURL() {
        let json = Data(fixtureWithName: "request_with_malformed_url")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Response.self, from: json),
                             "A Track with a malformed request URL should fail.")
    }

    func testInvalidRequestWithMalformedURLAsObject() {
        let json = Data(fixtureWithName: "request_with_malformed_url_as_object")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Response.self, from: json),
                             "A Track with a malformed request URL should fail.")
    }

    func testInvalidRequestHeaderJSONPropertyIsString() {
        let json = Data(fixtureWithName: "request_with_malformed_headers")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Response.self, from: json),
                             "A Track whose header is not a JSON object should fail.")
    }

    func testInvalidRequestHeaderJSONObjectHasInteger() {
        let json = Data(fixtureWithName: "request_with_malformed_header_integer")
        XCTAssertThrowsError(try JSONDecoder().decode(Track.Response.self, from: json),
                             "A Track whose header is not a JSON object should fail.")
    }

    // MARK: - JSON that does create a valid Response

    func testValidResponseWithTextBody() {
        let json = Data(fixtureWithName: "response_valid_with_text_body")
        let response = XCTAssertNoThrowAndReturn(try JSONDecoder().decode(Track.Response.self, from: json))
        XCTAssertEqual(response?.url, URL(string: "http://api.test.com"))
        XCTAssertEqual(response?.statusCode, 200)
        XCTAssertEqual(response?.body?.string, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
    }

    func testValidResponseWithoutStatusCode() {
        let json = Data(fixtureWithName: "response_valid_without_status")
        let response = XCTAssertNoThrowAndReturn(try JSONDecoder().decode(Track.Response.self, from: json))
        XCTAssertNil(response?.statusCode)
        XCTAssertNil(HTTPURLResponse(using: response!))
    }

}
