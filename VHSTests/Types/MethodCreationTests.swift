//
//  MethodCreationTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

final class MethodCreationTests: XCTestCase {

    func testValidMethods() {
        XCTAssertEqual(Method(ignoringCase: "get"), .get)
        XCTAssertEqual(Method(ignoringCase: "Get"), .get)
        XCTAssertEqual(Method(ignoringCase: nil), .get)
    }

}
