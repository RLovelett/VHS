//
//  Track.swift
//  VHS
//
//  Created by Ryan Lovelett on 6/24/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

typealias HTTPHeaders = [String: String]

/// The `Track` type encapsulates all of the data necessary to recreate an HTTP interaction for
/// later re-use. Typically a `Track` instance is stored as a set inside a `Cassette`.
///
/// An HTTP interaction consists of two parts, a request and a response. Like wise, a `Track` wraps
/// two other types, `Track.Request` and `Track.Response`.
struct Track {

    /// A `Track.Request` represents the recorded `URLRequest` that should be used to match a given
    /// `Track` during playback.
    struct Request: VHS.Request {

        /// The `URL` that a request was made against.
        let url: URL

        /// The HTTP verb used to make a request.
        let method: Method

        /// The headers, if any, sent along with a request.
        let headers: HTTPHeaders?

        /// The data, if any, that was sent along with a request.
        let body: Body?

    }

    ///
    struct Response {

        /// The `URL` that a request was made against.
        let url: URL

        let statusCode: Int?

        /// The headers, if any, sent along with a request.
        let headers: HTTPHeaders?

        let error: NSError?

        /// The data, if any, that should be sent as the response for this track.
        let body: Body?

    }

    let request: Request

    let response: Response

}

// MARK: - Argo Decodable protocol conformance

extension Track: Decodable { }

extension Track.Request: Decodable {
    private enum Keys: String, CodingKey {
        case url, method, headers, body
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Track.Request.Keys.self)
        self.url = try container.decode(URL.self, forKey: .url)
        self.method = (try? container.decode(Method.self, forKey: .method)) ?? .get
        self.headers = try container.decodeIfPresent(HTTPHeaders.self, forKey: .headers)
        self.body = try container.decodeIfPresent(Body.self, forKey: .body)
    }
}

extension Track.Response: Decodable {
    private enum Keys: String, CodingKey {
        case url, status, headers, body
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Track.Response.Keys.self)
        self.url = try container.decode(URL.self, forKey: .url)
        self.statusCode = try container.decodeIfPresent(Int.self, forKey: .status)
        self.headers = try container.decodeIfPresent(HTTPHeaders.self, forKey: .headers)
        self.error = nil
        self.body = try container.decodeIfPresent(Body.self, forKey: .body)
    }
}
