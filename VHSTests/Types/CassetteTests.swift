//
//  CassetteTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/16/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

@testable import VHS
import XCTest

final class CassetteTests: XCTestCase {

    func testMissingFixture() {
        XCTAssertThrowsError(try Cassette(fixtureWithName: "🏅👻🍻")) { error in
            XCTAssertEqual(error as? VCR.Error, .missing(resource: "🏅👻🍻.json"))
        }
    }

    func testMalformedFixture() {
        XCTAssertThrowsError(try Cassette(fixtureWithName: "dvr_multiple")) { error in
            XCTAssertEqual(error as? VCR.Error, .invalidFormat(resource: "dvr_multiple.json"))
        }
    }

}
