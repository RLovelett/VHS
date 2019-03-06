//
//  ExpectResponseFromDelegate.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/19/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation
import XCTest

final class ExpectResponseFromDelegate: NSObject, URLSessionDataDelegate {

    enum QueueType {
        case `default`, main
    }

    private let type: QueueType

    private let expectation: XCTestExpectation

    private let file: StaticString

    private let line: UInt

    init(on type: QueueType, fulfill: XCTestExpectation, file: StaticString = #file, line: UInt = #line) {
        self.type = type
        self.expectation = fulfill
        self.file = file
        self.line = line
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        switch self.type {
        case .default:
            XCTAssertFalse(Thread.isMainThread, file: file, line: line)
        case .main:
            XCTAssertTrue(Thread.isMainThread, file: file, line: line)
        }

        self.expectation.fulfill()
    }

}
