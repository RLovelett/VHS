//
//  Method.swift
//  VHS
//
//  Created by Lovelett, Ryan A. on 5/16/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

import Foundation

/// A `Track.Request.Method` represents a set of possible HTTP verbs.
/// - seealso: [Hypertext Transfer Protocol -- HTTP/1.1 - Method Definitions](https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html)
public enum Method: String {
    case options, get, head, post, put, patch, delete, trace, connect
}

extension Method {
    /// Create an value from the provided `String`. The matching of available HTTP verbs is
    /// case-insensitive. Meaning that both `"get"` and `"GeT"` map to `Track.Request.Method.get`.
    /// If the argument does not match a valid HTTP verb, e.g., `"track"`, then the initializer will
    /// be `Track.Request.Method.get`.
    ///
    /// - parameter rawValue: The `String` to attempt to parse into a `Track.Request.Method` value.
    init(ignoringCase rawValue: String?) {
        let verb = rawValue?.lowercased() ?? ""
        if let method = Method(rawValue: verb) {
            self = method
        } else {
            self = .get
        }
    }
}

extension Method: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer()
        let string = container.flatMap { try? $0.decode(String.self) }
        self.init(ignoringCase: string)
    }
}
