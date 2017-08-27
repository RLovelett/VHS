//
//  Cassette.swift
//  VHS
//
//  Created by Ryan Lovelett on 6/24/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
import Foundation

/// HTTP interactions are recorded into a `Cassette` to be replayed later by a `VCR` instance.
/// A `Cassette` can be used to store many different HTTP interactions.
public struct Cassette {

    internal let tracks: [Track]

    /// Attempt to find and load a test fixture with the specified name having a `.json` extension.
    ///
    /// For example, loading a JSON fixture, ignoring any errors, that has the name "cassette.json":
    ///
    ///     let vhs = try! Cassette(fixtureWithName: "cassette")
    ///
    /// The `vhs` value can then be fed into a `VCR` instance to replay the stored HTTP
    /// interactions.
    ///
    /// - parameter fixtureWithName: The name of the fixture to find. Without the `.json`
    ///   file-extension.
    /// - throws: If the requested fixture cannot be found it throws `VCR.Error.missing`
    public init(fixtureWithName name: String) throws {
        let bundle = Bundle.allBundles.first(where: { $0.bundlePath.hasSuffix(".xctest") })
        guard let resource = bundle?.url(forResource: name, withExtension: "json")
            else { throw VCR.Error.missing(resource: name + ".json") }
        try self.init(contentsOf: resource)
    }

    /// Attempt to load the contents and parse the contents of a `URL`.
    ///
    /// - parameter contentsOf: The `URL` referencing the fixture to be loaded and parsed.
    /// - throws: If the fixture is malformed the function throws an `VCR.Error.invalidFormat`
    init(contentsOf fixture: URL) throws {
        let data = try Data(contentsOf: fixture)
        let foundationJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        let json = JSON(foundationJSON)
        let decodedTracks: Decoded<[Track]> = decodeArray(json)
        switch decodedTracks {
        case .success(let tracks):
            self.tracks = tracks
        case .failure:
            throw VCR.Error.invalidFormat(resource: fixture.description)
        }
    }

}
