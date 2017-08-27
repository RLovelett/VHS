//
//  TrackResponseTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/14/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
@testable import VHS
import XCTest

final class TrackResponseTests: XCTestCase {

    // MARK: - JSON that does not create a valid Response

    func testInvalidResponseEmptyJSONObject() {
        let json = JSON(withName: "request_empty") ?? JSON.null
        switch Track.Response.decode(json) {
        case .success:
            XCTFail("A Track with an empty Request should fail.")
        default:
            XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestWithoutURL() {
        let json = JSON(withName: "request_without_url") ?? JSON.null
        switch Track.Response.decode(json) {
        case .success:
            XCTFail("A Track without a request URL should fail.")
        default:
            XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestWithMalformedURL() {
        let json = JSON(withName: "request_with_malformed_url") ?? JSON.null
        switch Track.Response.decode(json) {
        case .success:
            XCTFail("A Track with a malformed request URL should fail.")
        default:
            XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestWithMalformedURLAsObject() {
        let json = JSON(withName: "request_with_malformed_url_as_object") ?? JSON.null
        switch Track.Response.decode(json) {
        case .success:
            XCTFail("A Track with a malformed request URL should fail.")
        default:
            XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestHeaderJSONPropertyIsString() {
        let json = JSON(withName: "request_with_malformed_headers") ?? JSON.null
        switch Track.Response.decode(json) {
        case .success:
            XCTFail("A Track whose header is not a JSON object should fail.")
        default:
            XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestHeaderJSONObjectHasInteger() {
        let json = JSON(withName: "request_with_malformed_header_integer") ?? JSON.null
        switch Track.Response.decode(json) {
        case .success:
            XCTFail("A Track whose header is not a JSON object should fail.")
        default:
            XCTAssertNotEqual(json, JSON.null)
        }
    }

    // MARK: - JSON that does create a valid Response

    func testValidResponseWithTextBody() {
        let json = JSON(withName: "response_valid_with_text_body") ?? JSON.null
        switch Track.Response.decode(json) {
        case .success(let response):
            let bodyAsText = response.body.flatMap({ String(data: $0, encoding: .utf8) })
            XCTAssertEqual(response.url, URL(string: "http://api.test.com"))
            XCTAssertEqual(response.statusCode, 200)
            XCTAssertEqual(response.type, .text)
            XCTAssertEqual(bodyAsText, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
        case .failure(let error):
            XCTFail(error.description)
        }
    }

    func testValidResponseWithoutStatusCode() {
        let json = JSON(withName: "response_valid_without_status") ?? JSON.null
        switch Track.Response.decode(json) {
        case .success(let response):
            XCTAssertNil(response.statusCode)
            XCTAssertNil(HTTPURLResponse(using: response))
        case .failure(let error):
            XCTFail(error.description)
        }
    }

}
