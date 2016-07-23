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
        case DefaultQueue, MainQueue
    }

    private let type: QueueType

    private let expectation: XCTestExpectation

    init(on type: QueueType, fulfill: XCTestExpectation) {
        self.type = type
        self.expectation = fulfill
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        switch self.type {
        case .DefaultQueue:
            XCTAssertFalse(Thread.isMainThread)
        case .MainQueue:
            XCTAssertTrue(Thread.isMainThread)
        }

        self.expectation.fulfill()
    }

}
