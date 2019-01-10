//
//  TestHelpers.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/12/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation
import XCTest

// Idea taken from Venmo/DVR/Vinyl (thanks!)
private func testingBundle() -> Bundle? {
    let bundleArray = Bundle.allBundles.filter { $0.bundlePath.hasSuffix(".xctest") }
    guard bundleArray.count == 1 else { return nil }
    return bundleArray.first
}

extension Data {
    init(fixtureWithName: String, fromBundle bundle: Bundle? = testingBundle(), file: StaticString = #file, line: UInt = #line) {
        if let url = bundle?.url(forResource: fixtureWithName, withExtension: "json") {
            do {
                try self.init(contentsOf: url)
            } catch {
                XCTFail("threw error \"\(error)\"", file: file, line: line)
                self.init()
            }
        } else {
            XCTFail("Bundle does not container fixture \"\(fixtureWithName).json\"", file: file, line: line)
            self.init()
        }
    }
}

func XCTAssertNoThrowAndReturn<T>(_ expression: @autoclosure () throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> T? {
    do {
        return try expression()
    } catch let error {
        XCTFail("threw error \"\(error)\"", file: file, line: line)
        return nil
    }
}
