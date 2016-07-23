//
//  CurryDelegateAsCallback.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/19/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation
import XCTest

final class CurryDelegateAsCallback: NSObject, URLSessionDataDelegate {

    private var data: Data?

    private var response: URLResponse?

    private var callback: (Data?, URLResponse?, Error?) -> Void

    init(_ callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.callback = callback
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        // TODO: This actually does not do anything. Just here for test coverage!
        completionHandler(URLSession.ResponseDisposition.allow)
        self.response = response
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data = data
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        self.callback(self.data, self.response, error)
    }

}
