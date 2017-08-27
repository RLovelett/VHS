//
//  VCRIntegrationTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/18/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//
// swiftlint:disable force_unwrapping
// swiftlint:disable implicitly_unwrapped_optional
// swiftlint:disable weak_delegate

import VHS
import XCTest

final class VCRIntegrationTests: XCTestCase {

    var multipleTracks: Cassette!

    var url: URL!

    typealias AsyncClosure = (XCTestExpectation) -> (Data?, URLResponse?, Error?) -> Void

    /// Ensure that the response callback properties match the first Track in the fixture
    /// "vinyl_method_path_and_headers".
    private let firstTrackResponseValidation: AsyncClosure = { (expectation) in
        return { (data, response, error) in
            // Ensure the data that comes out is right
            XCTAssertEqual(data.flatMap({ String(data: $0, encoding: .utf8) }), "No header match!")

            // Ensure the HTTPURLResponse is right
            let http = response as? HTTPURLResponse
            XCTAssertNotNil(http?.allHeaderFields)
            XCTAssertEqual(http?.mimeType, "text/plain")
            XCTAssertEqual(http?.statusCode, 200)
            XCTAssertEqual(http?.expectedContentLength, 16)
            XCTAssertEqual(http?.suggestedFilename, "headers.txt")
            XCTAssertEqual(http?.textEncodingName, "utf-8")
            XCTAssertEqual(http?.url, URL(string: "http://api.test1.com/get/with/no/headers"))

            // Ensure there are no errors
            XCTAssertNil(error)
            expectation.fulfill()
        }
    }

    /// Ensure that the response callback properties match a missing track.
    private let unmatchedTrackErrorValidation: AsyncClosure = { (expectation) in
        return { (data, response, error) in
            // Ensure that no response was provided
            XCTAssertNil(data)
            XCTAssertNil(response)

            // Ensure that the error is the expected kind
            XCTAssertNotNil(error)
//            XCTAssertEqual((error as NSError).code?.domain, "me.lovelett.VHS.VCRError")
//            XCTAssertEqual((error as? NSError)?.code, 404)
            XCTAssertEqual(error?.localizedDescription, "Unable to find match for request.")
            expectation.fulfill()
        }
    }

    override func setUp() {
        super.setUp()
        // Put setup code here.
        // This method is called before the invocation of each test method in the class.
        self.continueAfterFailure = false

        self.multipleTracks = try? Cassette(fixtureWithName: "vinyl_method_path_and_headers")
        XCTAssertNotNil(self.multipleTracks)

        self.url = URL(string: "http://api.test1.com")
        XCTAssertNotNil(self.url)

        self.continueAfterFailure = true
    }

    // MARK: - Test the tasks

    func testTaskProperties() {
        let t = VCR(play: self.multipleTracks)

        let firstTask = t.dataTask(with: self.url)
        XCTAssertEqual(firstTask.state, .suspended)
        XCTAssertNotNil(firstTask.originalRequest)
        XCTAssertNotNil(firstTask.currentRequest)

        let secondTask = t.dataTask(with: self.url)
        XCTAssertEqual(secondTask.state, .suspended)
        XCTAssertNotNil(secondTask.originalRequest)
        XCTAssertNotNil(secondTask.currentRequest)

        let thirdTask = t.dataTask(with: self.url)
        XCTAssertEqual(thirdTask.state, .suspended)
        XCTAssertNotNil(thirdTask.originalRequest)
        XCTAssertNotNil(thirdTask.currentRequest)

        // Ensure that the task identifiers are incrementing
        XCTAssertNotEqual(firstTask.taskIdentifier, secondTask.taskIdentifier)
        XCTAssertNotEqual(secondTask.taskIdentifier, thirdTask.taskIdentifier)
        XCTAssertNotEqual(firstTask.taskIdentifier, thirdTask.taskIdentifier)
        XCTAssertGreaterThan(secondTask.taskIdentifier, firstTask.taskIdentifier)

        // Ensure that the task's identifier is stable
        let stable = firstTask.taskIdentifier
        XCTAssertEqual(stable, firstTask.taskIdentifier)

        // Ensure that these methods to not SIGABRT;
        // mostly to increase code coverage since they are no-op
        firstTask.suspend()
        firstTask.cancel()
    }

    // MARK: - Testing the asynchronous callbacks

    func testCallbackOnDefaultQueue() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        let t = VCR(play: self.multipleTracks)
        let task = t.dataTask(with: self.url) { (_, _, _) in
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }

        task.resume()
    }

    func testCallbackOnMainQueue() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        let t = VCR(play: self.multipleTracks, in: OperationQueue.main)
        let task = t.dataTask(with: self.url) { (_, _, _) in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        task.resume()
    }

    func testNoCallbackWithoutCallingResume() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        let t = VCR(play: self.multipleTracks, match: .cassetteOrder, replay: .none)
        _ = t.dataTask(with: self.url) { (_, _, _) in
            XCTFail("This never should respond")
        }

        let good = t.dataTask(with: url) { (_, response, _) in
            XCTAssertNotNil(response)
            expectation.fulfill()
        }

        good.resume()
    }

    func testCallbackFromURL() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        VCR(play: self.multipleTracks)
            .dataTask(with: self.url, completionHandler: firstTrackResponseValidation(expectation))
            .resume()
    }

    func testCallbackUnlimitedPlaybackFromURL() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        VCR(play: self.multipleTracks, replay: .unlimited)
            .dataTask(with: self.url, completionHandler: firstTrackResponseValidation(expectation))
            .resume()
    }

    func testCallbackFromUnmatchedURL() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        let url = URL(string: "http://api.test3.com")!
        VCR(play: self.multipleTracks, match: .properties(matching: [.url]))
            .dataTask(with: url, completionHandler: unmatchedTrackErrorValidation(expectation))
            .resume()
    }

    // MARK: - Testing the asynchronous delegate

    var delegate: URLSessionDataDelegate!

    func testDelegatekOnDefaultQueue() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        delegate = ExpectResponseFromDelegate(on: .default, fulfill: expectation)
        VCR(play: self.multipleTracks, notify: delegate)
            .dataTask(with: self.url)
            .resume()
    }

    func testDelegateOnMainQueue() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        delegate = ExpectResponseFromDelegate(on: .main, fulfill: expectation)
        VCR(play: self.multipleTracks, in: OperationQueue.main, notify: delegate)
            .dataTask(with: self.url)
            .resume()
    }

    func testDelegateFromURL() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        delegate = CurryDelegateAsCallback(firstTrackResponseValidation(expectation))
        VCR(play: self.multipleTracks, notify: delegate)
            .dataTask(with: self.url)
            .resume()
    }

    func testDelegateUnlimitedPlaybackFromURL() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        delegate = CurryDelegateAsCallback(firstTrackResponseValidation(expectation))
        VCR(play: self.multipleTracks, replay: .unlimited, notify: delegate)
            .dataTask(with: self.url)
            .resume()
    }

    func testDelegateFromUnmatchedURL() throws {
        let expectation = self.expectation(description: #function)
        defer { self.waitForExpectations(timeout: 2.0, handler: nil) }

        delegate = CurryDelegateAsCallback(unmatchedTrackErrorValidation(expectation))
        VCR(play: self.multipleTracks, match: .properties(matching: [.url]), notify: delegate)
            .dataTask(with: URL(string: "http://api.test3.com")!)
            .resume()
    }

}
