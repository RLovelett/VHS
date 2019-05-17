//
//  VCR.swift
//  VHS
//
//  Created by Ryan Lovelett on 6/24/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation

/// A `VCR` instance is used to replay HTTP interactions from a predefined fixture. Often the
/// recorded interactions are provided as a collection contained in a `Cassette` instance.
///
/// The class extends [`URLSession`](https://developer.apple.com/reference/foundation/nsurlsession).
///
/// - SeeAlso: [Using NSURLSession](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/Articles/UsingNSURLSession.html)
// swiftlint:disable:next line_length
/// - SeeAlso: [About the URL Loading System](https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i)
public final class VCR: URLSession {

    /// A set of errors that may be encountered at run-time when interacting with a recored HTTP
    /// interaction.
    public enum Error {

        /// During VCR playback an attempt was made to match the
        /// [`URLRequest`](https://developer.apple.com/reference/foundation/nsurlrequest) provided
        /// in the associated value. However, no `Track` could be found that matched the request.
        ///
        /// - Note: This error is only expected when using a custom matcher.
        case recordNotFound(for: URLRequest)

        /// The VHS library was unable to find the resource provided in the associated value while
        /// attempting to load a `Cassette` fixture.
        case missing(resource: String)

        /// The fixture resource provided in the associated value is improperly formatted.
        case invalidFormat(resource: String)

    }

    /// A type that indicates how the `VCR` instance should playback the recorded HTTP interactions
    /// from the loaded `Cassette`.
    public enum PlaybackSequence {

        /// Ignoring the request made by the `dataTask` methods play the `Track`s in the `Cassette`
        /// in the order they are presented to the `VCR` instance.
        case cassetteOrder

        /// Using the request made by the `dataTask` methods attempt to use the supplied properties
        /// to match a `Track` in the `Cassette`.
        ///
        /// The set of `Track` instances in a `Cassette` have the `Array<MatchType>` applied to them
        /// if all the `MatchType` constraints match for a given `Track` that instance is assumed to
        /// match the matching constraint. If one, or more, `MatchType` does not match for a given
        /// `Track` then the `Track` is not considered a match.
        ///
        /// - Parameter matching: An `Array` of `MatchType` instances to construct a match between
        ///   a `Track.Request` instance and `URLRequest` instance.
        case properties(matching: [MatchType])

        /// A type the defines a property by which a `Track` and `URLRequest` are compared to see
        /// if they are a match.
        ///
        /// In order to properly replay previously recorded requests, VHS can match HTTP requests to
        /// a previously recorded one.
        public enum MatchType {

            /// The HTTP method (i.e. GET, POST, PUT or DELETE) of the request.
            case method

            /// The full URI of the request.
            case url

            /// Scheme of the URI.
            case scheme

            /// The path of the URI.
            case path

            /// The query string values of the URI. The query string ordering does not affect
            /// matching results (it's order-agnostic).
            case query

            /// The request headers.
            case headers

            /// The body of the request.
            case body

            /// A custom closure or function that can be defined outside of VHS.
            ///
            /// - Parameter using: A closure that compares two `Request` arguments using logic defined outside of VHS.
            ///   If the closure returns `true` it is assumed that the `Request` can be used for playback. If the
            ///   closure returns `false` it is assumed that the `Request` cannot be used for playback.
            case custom(using: (Request, Request) -> Bool)

        }

    }

    /// A type that indicates how many times the `VCR` instance should playback the recorded HTTP
    /// interactions from the loaded `Cassette`.
    public enum ReplayCount {

        /// Play each `Track` from a `Cassette` one time only.
        case none

        /// Play each `Track` from a `Cassette` as many times as necessary.
        case unlimited

    }

    fileprivate var sequence: VCRSequence

    fileprivate let queue: OperationQueue

    fileprivate weak var _delegate: URLSessionDelegate?

    /// Create a `VCR` instance to playback recorded HTTP interactions from a `Cassette`.
    ///
    /// - Parameter play: The `Cassette` containing the HTTP interactions to be played back.
    /// - Parameter in: The `OperationQueue` to send the asynchronous results back on. Defaults to
    ///   a new `OperationQueue` instance that can perform at most 1 operation at a time.
    /// - Parameter match: The order in which to playback the `Cassette`. Defaults to the
    ///  `Cassette`'s internal order.
    /// - Parameter replay: The number of times to replay the HTTP interactions in the `Cassette`.
    ///   Defaults to playing each `Track` one time only.
    /// - Parameter notify: A delegate to notify of session level events. Default is no delegate.
    public init(
        play cassette: Cassette,
        in queue: OperationQueue? = .none,
        match sequenceType: PlaybackSequence = .cassetteOrder,
        replay duration: ReplayCount = .none,
        notify delegate: URLSessionDelegate? = .none
    ) {
        switch duration {
        case .none:
            self.sequence = EphemeralSequence(sequenceOf: cassette.tracks, inOrder: sequenceType)
        case .unlimited:
            self.sequence = LoopingSequence(sequenceOf: cassette.tracks, inOrder: sequenceType)
        }

        if let queue = queue {
            self.queue = queue
        } else {
            self.queue = OperationQueue()
            self.queue.maxConcurrentOperationCount = 1
        }

        self._delegate = delegate

        super.init()
    }

}

// MARK: - Configuring a Session

extension VCR {

    /// The delegate assigned when this object was created.
    ///
    /// - Remark: This property is required by the base class.
    ///
    /// - Note: This delegate object must be set at object creation time and may not be changed.
    ///   This requirement comes from the base class `NSURLSession`.
    ///
    /// - SeeAlso: https://developer.apple.com/reference/foundation/nsurlsession/1411530-delegate
    override public var delegate: URLSessionDelegate? {
        return _delegate
    }

}

// MARK: - Adding Data Tasks to a Session

extension VCR {

    /// Creates a task that retrieves the contents of the specified URL.
    ///
    /// - Remark: This property is required by the base class.
    ///
    /// - SeeAlso: https://developer.apple.com/reference/foundation/nsurlsession/1411554-datatask
    public override func dataTask(with url: URL) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        return self.dataTask(with: request)
    }

    /// Creates a task that retrieves the contents of the specified URL, then calls a handler upon
    /// completion. The task bypasses calls to delegate methods for response and data delivery, and
    /// instead provides any resulting NSData, URLResponse, and NSError objects inside the
    /// completion handler. Delegate methods for handling authentication challenges, however, are
    /// still called.
    ///
    /// - Remark: This property is required by the base class.
    ///
    /// - SeeAlso: https://developer.apple.com/reference/foundation/nsurlsession/1410330-datatask
    public override func dataTask(with request: URLRequest) -> URLSessionDataTask {
        return self.dataTask(with: request, completionHandler: { (_, _, _) in })
    }

    /// Creates a task that retrieves the contents of a URL based on the specified URL request
    /// object.
    ///
    /// - Remark: This property is required by the base class.
    ///
    /// - SeeAlso: https://developer.apple.com/reference/foundation/nsurlsession/1410592-datatask
    public override func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void
    ) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        return self.dataTask(with: request, completionHandler: completionHandler)
    }

    /// Creates a task that retrieves the contents of a URL based on the specified URL request
    /// object, and calls a handler upon completion. The task bypasses calls to delegate methods for
    /// response and data delivery, and instead provides any resulting NSData, URLResponse, and
    /// NSError objects inside the completion handler. Delegate methods for handling authentication
    /// challenges, however, are still called.
    ///
    /// - Remark: This property is required by the base class.
    ///
    /// - SeeAlso: https://developer.apple.com/reference/foundation/nsurlsession/1407613-datatask
    public override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void
    ) -> URLSessionDataTask {
        guard let response = self.sequence.next(for: AnyRequest(request))?.response else {
            let error = Error.recordNotFound(for: request).error()
            let task = VCRTask(send: error, for: request, whenCompleteCall: completionHandler)
            task.queue = self.queue
            task.delegate = self.delegate as? URLSessionDataDelegate
            return task
        }

        let task = VCRTask(send: response, for: request, whenCompleteCall: completionHandler)
        task.queue = self.queue
        task.delegate = self.delegate as? URLSessionDataDelegate
        return task
    }

}

/// Extract the `URLQueryItem`s from an `URL` instance and sort them by name.
private func thing(from url: URL) -> [URLQueryItem]? {
    let temp = URLComponents(url: url, resolvingAgainstBaseURL: true)?
        .queryItems?.lazy.sorted(by: { $0.name < $1.name })
    return temp
}

extension VCR.PlaybackSequence.MatchType {

    // swiftlint:disable:next cyclomatic_complexity
    func match(_ track: Request, with request: Request) -> Bool {
        switch self {
        case .method:
            return track.method == request.method
        case .url:
            return track.url == request.url
        case .scheme:
            return track.url.scheme == request.url.scheme
        case .path:
            return track.url.path == request.url.path
        case .query:
            switch (thing(from: track.url), thing(from: request.url)) {
            case (let trackQueryItems?, let rquestQueryItems?):
                return trackQueryItems == rquestQueryItems
            default:
                return false
            }
        case .headers:
            switch (track.headers, request.headers) {
            case (let trackHeaders?, let requestHeaders?):
                return trackHeaders == requestHeaders
            default:
                return false
            }
        case .body:
            switch (track.body?.data, request.body?.data) {
            case (let trackBody?, let requestBody?):
                return trackBody == requestBody
            case (nil, nil):
                return true
            default:
                return false
            }
        case .custom(let matchUsing):
            return matchUsing(track, request)
        }
    }

}

extension VCR.Error: CustomErrorConvertible {

    func userInfo() -> [String: String]? {
        return [
            NSLocalizedDescriptionKey: "Unable to find match for request.",
        ]
    }

    func domain() -> String {
        return "me.lovelett.VHS.VCRError"
    }

    func code() -> Int {
        switch self {
        case .recordNotFound:
            return 404
        default:
            return 500
        }
    }

}

extension VCR.Error: Equatable {
    public static func == (lhs: VCR.Error, rhs: VCR.Error) -> Bool {
        switch (lhs, rhs) {
        case (.invalidFormat(let lhs), .invalidFormat(let rhs)),
             (.missing(let lhs), .missing(let rhs)):
            return lhs == rhs
        case (.recordNotFound(let lhs), .recordNotFound(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}
