//
//  TrackRequestMethodCreationTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
import SwiftCheck
@testable import VHS
import XCTest

private let verbs = [
    "options",
    "head",
    "post",
    "put",
    "patch",
    "delete",
    "trace",
    "connect"
].flatMap { (verb) in
    (0..<100).map({ _ in verb.randomizeCase() })
}

private let methods: [Track.Request.Method] = [
    .options,
    .head,
    .post,
    .put,
    .patch,
    .delete,
    .trace,
    .connect
]

private let arbitraryVerbs = Gen<String>.frequency([
    (1, String.arbitrary),
    (3, Gen<Character>.fromElements(of: verbs))
])

private struct OptionalArbitraryVerb: Arbitrary {
    let verb: String?

    static var arbitrary: Gen<OptionalArbitraryVerb> {
        let optionalVerbs = Gen<String?>.frequency([
            (1, Gen<String?>.pure(nil)),
            (3, arbitraryVerbs.map(Optional.some))
        ])

        return optionalVerbs.map(OptionalArbitraryVerb.init)
    }
}

private let arbitraryBooleanJSON: Gen<JSON> = Bool.arbitrary.map(JSON.bool)

private let arbitraryStringJSON: Gen<JSON> = arbitraryVerbs.map(JSON.string)

private let arbitraryObjectJSON: Gen<JSON> = Gen<JSON>.compose(build: { (c) in
    let str = String.arbitrary.suchThat { !$0.isEmpty }
    let dictionary: [ String : JSON ] = [
        str.generate : JSON.string(c.generate()),
        str.generate : JSON.bool(c.generate())
    ]
    return JSON.object(dictionary)
})

private let arbitraryJSON: Gen<JSON> = Gen<JSON>.frequency([
    (1, Gen.pure(JSON.null)),
    (1, arbitraryBooleanJSON),
    (2, arbitraryStringJSON),
    (2, arbitraryObjectJSON)
])

final class TrackRequestMethodCreationTests: XCTestCase {

    /// Use SwiftCheck to generate a random set of HTTP verbs. Some are garbage strings others are
    /// verbs with random case noise applied to their characters.
    func testValidMethods() {
        property("Create request method from arbitrary HTTP verb `String?`") <- forAll { (aVerb: OptionalArbitraryVerb) in
            // swiftlint:disable:previous line_length
            let optionalVerb = aVerb.verb
            let method = Track.Request.Method(ignoringCase: optionalVerb)
            if let verb = optionalVerb, verbs.contains(verb) {
                // I've excluded `.get` from the available verbs
                // Therefore if a verb was found it should NOT be `.get`
                return method != .get
            } else {
                // If the verb is Optional.none then it should be a `.get` method
                // If the verb does not exist the array of verbs it should be a `.get` method
                return method == .get
            }
        }
    }

    func testDecodingFromJSON() {
        property("Create request method from JSON.String") <- forAll(arbitraryJSON) { (json) in
            let result = Track.Request.Method.decode(json)
            switch (json, result) {
            case (.string(_), .success(_)):
                return true
            case (_, .failure(_)):
                return true
            default: return false
            }
        }
    }

}
