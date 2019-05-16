//
//  MockRequest.swift
//  VHSTests
//
//  Created by Lovelett, Ryan A. on 5/16/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

import Foundation
@testable import VHS

struct MockRequest: VHS.Request {
    let url: URL
    let method: VHS.Method
    let headers: [String: String]?
    let body: Body?

    init?(url: URL?) {
        guard let url = url else {
            return nil
        }
        self.init(url: url, method: .get, headers: nil, body: nil)
    }

    init(url: URL) {
        self.init(url: url, method: .get, headers: nil, body: nil)
    }

    init(url: URL, method: VHS.Method) {
        self.init(url: url, method: method, headers: nil, body: nil)
    }

    init(url: URL, headers: [String: String]?) {
        self.init(url: url, method: .get, headers: headers, body: nil)
    }

    init(url: URL, base64: String) {
        self.init(url: url, method: .get, headers: nil, body: Body(Data(base64Encoded: base64)))
    }

    init(url: URL, method: VHS.Method, headers: [String: String]?, body: Body?) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}
