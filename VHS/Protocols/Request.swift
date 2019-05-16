//
//  Request.swift
//  VHS
//
//  Created by Lovelett, Ryan A. on 5/16/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

import Foundation

/// A type that represents all the data used in a request.
public protocol Request {
    /// The `URL` the request was made against
    var url: URL { get }
    /// The HTTP verb the request used
    var method: Method { get }
    /// The headers, if any, sent with the request
    var headers: [String: String]? { get }
    /// The data, if any, sent as the message body of the request, as is done in an HTTP POST request.
    var body: Body? { get }
}

struct AnyRequest: Request {
    let url: URL
    let method: Method
    let headers: [String: String]?
    let body: Body?

    init(_ request: URLRequest) {
        assert(request.url != nil)
        // swiftlint:disable:next force_unwrapping
        self.url = request.url!
        self.method = Method(ignoringCase: request.httpMethod)
        self.headers = request.allHTTPHeaderFields
        self.body = Body(request.httpBody)
    }
}
