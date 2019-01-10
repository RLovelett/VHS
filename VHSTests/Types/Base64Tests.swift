//
//  Base64Tests.swift
//  VHSTests
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

class Base64Tests: XCTestCase {

    func testDoesNotHandleVariationMimeTypes() {
        XCTAssertFalse(Base64.handle("foo"))
        XCTAssertFalse(Base64.handle("text/html"))
        XCTAssertFalse(Base64.handle("application/json"))
    }

    func testHandleNilValue() {
        XCTAssertTrue(Base64.handle(nil))
    }

    func testDecodesJSON() throws {
        let json = """
        {
            "base64": "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let dict = XCTAssertNoThrowAndReturn(try decoder.decode([String: Base64].self, from: json))
        let string = dict?["base64"].flatMap { $0.data }.flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(string, "{\"username\":\"ziggy\",\"password\":\"stardust\"}")
    }

}
