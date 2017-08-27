//
//  Track.swift
//  VHS
//
//  Created by Ryan Lovelett on 6/24/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
import Curry
import Foundation
import Runes

typealias HTTPHeaders = [String : String]

/// The `Track` type encapsulates all of the data necessary to recreate an HTTP interaction for
/// later re-use. Typically a `Track` instance is stored as a set inside a `Cassette`.
///
/// An HTTP interaction consists of two parts, a request and a response. Like wise, a `Track` wraps
/// two other types, `Track.Request` and `Track.Response`.
public struct Track {

    /// A `Track.ContentType` represents a set of possible types that this library will manage. It
    /// also provides the mechanism by which the `rawBody` element will be parsed.
    internal enum ContentType {
        case json, text, base64
    }

    /// A `Track.Request` represents the recorded `URLRequest` that should be used to match a given
    /// `Track` during playback.
    struct Request {

        /// A `Track.Request.Method` represents a set of possible HTTP verbs.
        /// - seealso: [Hypertext Transfer Protocol -- HTTP/1.1 - Method Definitions](https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html)
        // swiftlint:disable:previous line_length
        enum Method {
            case options, get, head, post, put, patch, delete, trace, connect
        }

        /// The `URL` that a request was made against.
        let url: URL

        /// The HTTP verb used to make a request.
        let method: Method

        /// The headers, if any, sent along with a request.
        let headers: HTTPHeaders?

        /// This is the parsed `body` property from the JSON fixture.
        fileprivate let rawBody: JSON?

        /// The type of data the `body` property from the JSON fixture represents.
        internal let type: Track.ContentType

        /// The data, if any, that was sent along with a request.
        var body: Data? {
            return self.rawBody.flatMap(self.type.decode(body:))
        }

    }

    ///
    struct Response {

        /// The `URL` that a request was made against.
        let url: URL

        let statusCode: Int?

        /// The headers, if any, sent along with a request.
        let headers: HTTPHeaders?

        /// This is the parsed `body` property from the JSON fixture.
        fileprivate let rawBody: JSON?

        /// The type of data the `body` property from the JSON fixture represents.
        internal let type: Track.ContentType

        let error: NSError?

        /// The data, if any, that should be sent as the response for this track.
        var body: Data? {
            return self.rawBody.flatMap(self.type.decode(body:))
        }

    }

    let request: Request

    let response: Response

}

// MARK: - Decode ContentType into Data

extension Track.ContentType {
    init(from headers: HTTPHeaders?) {
        let type = headers?.lazy
            .first(where: { (key, _) in key.lowercased() == "content-type" })
            .map({ (_, value) in value })
        switch type {
        case .some(let type) where type.lowercased().hasPrefix("application/json"):
            self = .json
        case .some(let type) where type.lowercased().hasPrefix("text/"):
            self = .text
        default:
            self = .base64
        }
    }

    func decode(body: JSON) -> Data? {
        switch (body, self) {
        case (.string(let str), .text):
            return str.data(using: .utf8)
        case (.string(let str), .base64):
            return Data(base64Encoded: str)
        case (.object, .json):
            let obj = body.encode()
            return try? JSONSerialization.data(withJSONObject: obj, options: [])
        default:
            return nil
        }
    }
}

extension Track.Request.Method {
    /// Create an value from the provided `String`. The matching of available HTTP verbs is
    /// case-insensitive. Meaning that both `"get"` and `"GeT"` map to `Track.Request.Method.get`.
    /// If the argument does not match a valid HTTP verb, e.g., `"track"`, then the initializer will
    /// be `Track.Request.Method.get`.
    ///
    /// - parameter rawValue: The `String` to attempt to parse into a `Track.Request.Method` value.
    init(ignoringCase rawValue: String?) {
        let verb = rawValue?.lowercased() ?? "get"
        switch verb {
        case "options":
            self = .options
        case "get":
            self = .get
        case "head":
            self = .head
        case "post":
            self = .post
        case "put":
            self = .put
        case "patch":
            self = .patch
        case "delete":
            self = .delete
        case "trace":
            self = .trace
        case "connect":
            self = .connect
        default:
            self = .get
        }
    }
}

// MARK: - Argo Decodable protocol conformance

extension Track : Argo.Decodable {
    /// Attempt to parse the JSON provided into a `Track` type.
    ///
    /// - parameter _: The JSON to parse.
    /// - returns: The result of the attempted parsing.
    public static func decode(_ json: JSON) -> Decoded<Track> {
        let request: Decoded<Request> = (json <| "request")
        let response: Decoded<Response> = (json <| "response")
        return curry(Track.init(request:response:))
            <^> request
            <*> response
    }
}

extension Track.Request : Argo.Decodable {
    init(
        from url: URL,
        using method: Method,
        with headers: HTTPHeaders? = nil,
        sending data: JSON? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.rawBody = data
        self.type = Track.ContentType(from: self.headers)
    }

    static func decode(_ json: JSON) -> Decoded<Track.Request> {
        let url: Decoded<URL> = (json <| "url") >>- decode(json:)
        let method: Decoded<Track.Request.Method> = (json <| "method") <|> pure(.get)
        let headers: Decoded<HTTPHeaders?> = (json <|? "headers").flatMap(decodeHeader(from:))
        let body: Decoded<JSON?> = (json <|? "body")
        return curry(Track.Request.init(from:using:with:sending:))
            <^> url
            <*> method
            <*> headers
            <*> body
    }
}

extension Track.Response : Argo.Decodable {
    init(
        from url: URL,
        providing code: Int?,
        with headers: HTTPHeaders? = nil,
        sending data: JSON? = nil
    ) {
        self.url = url
        self.statusCode = code
        self.headers = headers
        self.rawBody = data
        self.type = Track.ContentType(from: self.headers)
        self.error = nil
    }

    static func decode(_ json: JSON) -> Decoded<Track.Response> {
        let url: Decoded<URL> = (json <| "url") >>- decode(json: )
        let statusCode: Decoded<Int?> = (json <|? "status")
        let headers: Decoded<HTTPHeaders?> = (json <|? "headers").flatMap(decodeHeader(from:))
        let body: Decoded<JSON?> = (json <|? "body")
        return curry(Track.Response.init(from:providing:with:sending:))
            <^> url
            <*> statusCode
            <*> headers
            <*> body
    }
}

extension Track.Request.Method : Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<Track.Request.Method> {
        switch json {
        case let .string(s):
            return pure(self.init(ignoringCase: s))
        default:
            return .typeMismatch(expected: "String", actual: json)
        }
    }
}
