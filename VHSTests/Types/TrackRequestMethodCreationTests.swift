//
//  TrackRequestMethodCreationTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

final class TrackRequestMethodCreationTests: XCTestCase {

    func testValidMethods() {
        XCTAssertEqual(Track.Request.Method(ignoringCase: "get"), .get)
        XCTAssertEqual(Track.Request.Method(ignoringCase: "Get"), .get)
        XCTAssertEqual(Track.Request.Method(ignoringCase: nil), .get)
    }

}
