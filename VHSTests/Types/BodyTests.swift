//
//  BodyTests.swift
//  VHSTests
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

class BodyTests: XCTestCase {

    func testDecodePlainText() {
        let json = """
        {
            "headers": {
                "Content-Type": "text/plain;charset=utf-8"
            },
            "body": "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let body = XCTAssertNoThrowAndReturn(try decoder.decode(Body.self, from: json))
        XCTAssertEqual(body?.data, Data(base64Encoded: "ZXlKMWMyVnlibUZ0WlNJNklucHBaMmQ1SWl3aWNHRnpjM2R2Y21RaU9pSnpkR0Z5WkhWemRDSjk="))
    }

    func testDecodeBase64EncodedString() {
        let json = """
        {
            "headers": {},
            "body": "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let body = XCTAssertNoThrowAndReturn(try decoder.decode(Body.self, from: json))
        XCTAssertEqual(body?.data, Data(base64Encoded: "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9"))
    }

    func testDecodeJSONObject() throws {
        let json = """
        {
            "headers": {
                "Content-Type": "application/json"
            },
            "body": {"username":"ziggy","password":"stardust"}
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let body = XCTAssertNoThrowAndReturn(try decoder.decode(Body.self, from: json))
        XCTAssertEqual(body?.data, Data(base64Encoded: "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9"))
    }

}
