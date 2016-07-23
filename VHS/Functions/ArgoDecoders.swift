//
//  ArgoDecoders.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
import Foundation

/// Create a tuple of `String` values from the provided key and value.
///
/// - parameter key: This value is merely copied to the resulting tuple.
/// - parameter value: The value to check if the resulting tuple can be constructed. Expected to be
///   of type `JSON.String`.
/// - returns: `.none` if the `value` parameter is not a `JSON.String`. Otherwise the parameter
///   `value` is unwrapped and returned as a tuple with the key.
private func mapJSONToString(key: String, value: JSON) -> (key: String, value: String)? {
    guard case .string(let string) = value else { return nil }
    return (key: key, value: string)
}

/// Decode a `JSON` type into a `URL` type.
///
/// Example:
/// ========
///
///     let json = JSON.String("http://api.test.com")
///     let url = decode(json) // url should have succeeded
///
/// - parameter json: A `JSON.String` value to attempt to parse as a `URL`.
/// - returns: The decoded `URL` along with any relavent error information.
func decode(json: JSON) -> Decoded<URL> {
    switch json {
    case .string(let urlString):
        let decodedURL: Decoded<URL>? = URL(string: urlString).map(pure)
        return decodedURL ?? .typeMismatch(expected: "URL", actual: json)
    default: return .typeMismatch(expected: "URL", actual: json)
    }
}

/// Decode a `JSON` type into a `[String : String]`.
///
/// Example:
/// ========
///
///     let json = JSON.Object(["one": 2])
///     // decoding should fail because `2` is not a `String`
///     let headers = decodeHeader(from: json)
///
/// - parameter json: A `JSON.Object` value to attempt to parse into a `[String : String]`.
/// - returns: The decoded `Dictionary` along with any relavent error information.
func decodeHeader(from json: JSON?) -> Decoded<HTTPHeaders?> {
    guard let json = json else { return pure(nil) }
    switch json {
    case .object(let dictionary):
        let headers = Dictionary(dictionary.lazy.flatMap(mapJSONToString(key:value:)))
        guard headers.count == dictionary.count else {
            return .typeMismatch(expected: "[String : String]", actual: json)
        }
        return pure(headers)
    default: return .typeMismatch(expected: "[String : String]", actual: json)
    }
}
