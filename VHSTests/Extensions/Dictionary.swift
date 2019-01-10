//
//  Dictionary.swift
//  VHSTests
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

final class DictionaryTests: XCTestCase {

    let dictionary = [
        "Content-Type": 1,
    ]

    func testCaseInsensitiveKeyInDictionary() {
        XCTAssertEqual(dictionary[caseInsensitive: "content-type"], 1)
        XCTAssertNil(dictionary[caseInsensitive: "ryan"])
    }

}
