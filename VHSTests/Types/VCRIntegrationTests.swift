//
//  VCRIntegrationTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/18/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

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
        let t = VCR(play: multipleTracks)

        let firstTask = t.dataTask(with: url)
        XCTAssertEqual(firstTask.state, .suspended)
        XCTAssertNotNil(firstTask.originalRequest)
        XCTAssertNotNil(firstTask.currentRequest)

        let secondTask = t.dataTask(with: url)
        XCTAssertEqual(secondTask.state, .suspended)
        XCTAssertNotNil(secondTask.originalRequest)
        XCTAssertNotNil(secondTask.currentRequest)

        let thirdTask = t.dataTask(with: url)
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
        let dataTaskExpectation = expectation(description: #function)

        let t = VCR(play: multipleTracks)
        let task = t.dataTask(with: url) { (_, _, _) in
            XCTAssertFalse(Thread.isMainThread)
            dataTaskExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testCallbackOnMainQueue() throws {
        let dataTaskExpectation = expectation(description: #function)

        let t = VCR(play: multipleTracks, in: OperationQueue.main)
        let task = t.dataTask(with: url) { (_, _, _) in
            XCTAssertTrue(Thread.isMainThread)
            dataTaskExpectation.fulfill()
        }

        task.resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testNoCallbackWithoutCallingResume() throws {
        let dataTaskExpectation = expectation(description: #function)

        let t = VCR(play: multipleTracks, match: .cassetteOrder, replay: .none)
        _ = t.dataTask(with: url) { (_, _, _) in
            XCTFail("This never should respond")
        }

        let good = t.dataTask(with: url) { (_, response, _) in
            XCTAssertNotNil(response)
            dataTaskExpectation.fulfill()
        }

        good.resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testCallbackFromURL() throws {
        let dataTaskExpectation = expectation(description: #function)

        VCR(play: multipleTracks)
            .dataTask(with: url, completionHandler: firstTrackResponseValidation(dataTaskExpectation))
            .resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testCallbackUnlimitedPlaybackFromURL() throws {
        let dataTaskExpectation = expectation(description: #function)

        VCR(play: multipleTracks, replay: .unlimited)
            .dataTask(with: url, completionHandler: firstTrackResponseValidation(dataTaskExpectation))
            .resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testCallbackFromUnmatchedURL() throws {
        let dataTaskExpectation = expectation(description: #function)

        let url = URL(string: "http://api.test3.com")!
        VCR(play: multipleTracks, match: .properties(matching: [.url]))
            .dataTask(with: url, completionHandler: unmatchedTrackErrorValidation(dataTaskExpectation))
            .resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    // MARK: - Testing the asynchronous delegate

    func testDelegatekOnDefaultQueue() throws {
        let dataTaskExpectation = expectation(description: #function)

        let delegate = ExpectResponseFromDelegate(on: .default, fulfill: dataTaskExpectation)
        VCR(play: multipleTracks, notify: delegate)
            .dataTask(with: url)
            .resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testDelegateOnMainQueue() throws {
        let dataTaskExpectation = expectation(description: #function)

        let delegate = ExpectResponseFromDelegate(on: .main, fulfill: dataTaskExpectation)
        VCR(play: multipleTracks, in: OperationQueue.main, notify: delegate)
            .dataTask(with: url)
            .resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testDelegateFromURL() throws {
        let dataTaskExpectation = expectation(description: #function)

        let delegate = CurryDelegateAsCallback(firstTrackResponseValidation(dataTaskExpectation))
        VCR(play: multipleTracks, notify: delegate)
            .dataTask(with: url)
            .resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testDelegateUnlimitedPlaybackFromURL() throws {
        let dataTaskExpectation = expectation(description: #function)

        let delegate = CurryDelegateAsCallback(firstTrackResponseValidation(dataTaskExpectation))
        VCR(play: multipleTracks, replay: .unlimited, notify: delegate)
            .dataTask(with: url)
            .resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testDelegateFromUnmatchedURL() throws {
        let dataTaskExpectation = expectation(description: #function)

        let delegate = CurryDelegateAsCallback(unmatchedTrackErrorValidation(dataTaskExpectation))
        VCR(play: multipleTracks, match: .properties(matching: [.url]), notify: delegate)
            .dataTask(with: URL(string: "http://api.test3.com")!)
            .resume()

        waitForExpectations(timeout: 2.0, handler: nil)
    }

}
