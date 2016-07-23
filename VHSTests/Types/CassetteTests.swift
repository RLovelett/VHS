//
//  CassetteTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/16/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import XCTest
@testable import VHS

final class CassetteTests: XCTestCase {

    func testMissingFixture() {
        do {
            let _ = try Cassette(fixtureWithName: "🏅👻🍻")
        } catch VCR.Error.missing(let name) {
            XCTAssertEqual(name, "🏅👻🍻.json")
        } catch let error as NSError {
            XCTFail(error.description)
        }
    }

    func testMalformedFixture() {
        do {
            let _ = try Cassette(fixtureWithName: "dvr_multiple")
        } catch VCR.Error.invalidFormat(let name) {
            XCTAssertTrue(name.contains("dvr_multiple.json"))
        } catch let error as NSError {
            XCTFail(error.description)
        }
    }

}
