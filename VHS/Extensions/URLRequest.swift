//
//  URLRequest.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/15/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation

extension URLRequest {
    /// Parse the `httpMethod` into a `Track.Request.Method`
    /// - Returns: The `Track.Request.Method` that the `httpMethod` corresponds to.
    ///
    /// - Remark: Though `httpMethod` appears to be `Optional`. In practice it never returns a
    /// `.none`. Even if the property remains unset it returns `"get"`. This was creating an
    /// corner-case I could not test for. Therefore, to increase code-coverage I've refactored
    /// `Track.Request.Method` initializer to accept an `String?` and could then test the
    /// corner-case there.
    var method: Track.Request.Method {
        return Track.Request.Method(ignoringCase: self.httpMethod)
    }
}
