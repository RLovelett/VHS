//
//  TextTests.swift
//  VHSTests
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

class TextTests: XCTestCase {

    func testHandlesVariationOfTextMimeTypes() {
        XCTAssertFalse(Text.handle("foo"))
        XCTAssertTrue(Text.handle("text/html"))
        XCTAssertFalse(Text.handle("application/json"))
    }

    func testDoesNotHandleNilValue() {
        XCTAssertFalse(Text.handle(nil))
    }

    func testDecodesJSON() {
        let json = """
        {
            "text": "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9"
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        let dict = XCTAssertNoThrowAndReturn(try decoder.decode([String: Text].self, from: json))
        let string = dict?["text"].flatMap { $0.data }.flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(string, "eyJ1c2VybmFtZSI6InppZ2d5IiwicGFzc3dvcmQiOiJzdGFyZHVzdCJ9")
    }

}
