//
//  TrackRequestTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 6/25/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
import XCTest
@testable import VHS

final class TrackRequestTests: XCTestCase {

    // MARK: - JSON that does not create a valid Request

    func testInvalidRequestEmptyJSONObject() {
        let json = JSON(withName: "request_empty") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(_): XCTFail("A Track with an empty Request should fail.")
        default: XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestWithoutURL() {
        let json = JSON(withName: "request_without_url") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(_): XCTFail("A Track without a request URL should fail.")
        default: XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestWithMalformedURL() {
        let json = JSON(withName: "request_with_malformed_url") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(_): XCTFail("A Track with a malformed request URL should fail.")
        default: XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestWithMalformedURLAsObject() {
        let json = JSON(withName: "request_with_malformed_url_as_object") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(_): XCTFail("A Track with a malformed request URL should fail.")
        default: XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestHeaderJSONPropertyIsString() {
        let json = JSON(withName: "request_with_malformed_headers") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(_): XCTFail("A Track whose header is not a JSON object should fail.")
        default: XCTAssertNotEqual(json, JSON.null)
        }
    }

    func testInvalidRequestHeaderJSONObjectHasInteger() {
        let json = JSON(withName: "request_with_malformed_header_integer") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(_): XCTFail("A Track whose header is not a JSON object should fail.")
        default: XCTAssertNotEqual(json, JSON.null)
        }
    }

    // MARK: - JSON that does create a valid Request

    func testValidRequestWithoutMethod() {
        let json = JSON(withName: "request_without_method") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(let request):
            XCTAssertEqual(request.method, .get)
            XCTAssertEqual(request.url, URL(string: "http://opera.com/faucibus/orci/luctus.xml"))
            XCTAssertEqual(request.type, .base64)
            XCTAssertNil(request.body)
        case .failure(let error): XCTFail(error.description)
        }
    }

    func testValidRequestWithURLAndGetMethod() {
        let json = JSON(withName: "request_with_url_and_get") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(let request):
            XCTAssertEqual(request.method, .get)
            XCTAssertEqual(request.url, URL(string: "http://opera.com/faucibus/orci/luctus.xml"))
            XCTAssertEqual(request.type, .base64)
            XCTAssertNil(request.body)
        case .failure(let error): XCTFail(error.description)
        }
    }

    func testValidRequestWithTextBody() {
        let json = JSON(withName: "request_with_text_body") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(let request):
            let bodyAsText = request.body.flatMap({ String(data: $0, encoding: .utf8) })
            XCTAssertEqual(request.method, .post)
            XCTAssertEqual(request.url, URL(string: "http://api.test.com"))
            XCTAssertEqual(request.type, .text)
            XCTAssertEqual(bodyAsText, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
        case .failure(let error): XCTFail(error.description)
        }
    }

    func testValidRequestWithBase64EncodedText() {
        let json = JSON(withName: "request_with_base64_body") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(let request):
            let bodyAsText = request.body.flatMap({ String(data: $0, encoding: .utf8) })
            let bodyAsBase64 = request.body?.base64EncodedString()
            XCTAssertEqual(request.method, .post)
            XCTAssertEqual(request.url, URL(string: "http://api.test.com"))
            XCTAssertEqual(request.type, .base64)
            XCTAssertEqual(bodyAsText, "{\"username\":\"ziggy\",\"password\":\"stardust\"}")
            XCTAssertEqual(bodyAsBase64, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
        case .failure(let error): XCTFail(error.description)
        }
    }

    func testValidRequestWithJSONBody() {
        let json = JSON(withName: "request_with_json_body") ?? JSON.null
        switch Track.Request.decode(json) {
        case .success(let request):
            let bodyAsBase64 = request.body?.base64EncodedString()
            XCTAssertEqual(request.method, .post)
            XCTAssertEqual(request.url, URL(string: "http://api.test.com"))
            XCTAssertEqual(request.type, .json)
            XCTAssertEqual(bodyAsBase64, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
        case .failure(let error): XCTFail(error.description)
        }
    }
}
