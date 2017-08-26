//
//  URL+Arbitrary.swift
//  VHS
//
//  Created by Ryan Lovelett on 6/24/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation
import SwiftCheck

// Concatenates an array of `String` `Gen`erators together in order.
private func glue(parts: [Gen<String>]) -> Gen<String> {
    return sequence(parts).map { $0.reduce("", +) }
}

private let lowalpha: Gen<Character> = .fromElements(in: "a"..."z")
private let upalpha: Gen<Character> = .fromElements(in: "A"..."Z")
private let digit: Gen<Character> = .fromElements(in: "0"..."9")
private let alpha: Gen<Character> = .one(of: [lowalpha, upalpha])
private let alphanum: Gen<Character> = .one(of: [alpha, digit])
private let mark: Gen<Character> = .fromElements(of: ["-", "_", ".", "!", "~", "*", "'", "(", ")"])
private let unreserved: Gen<Character> = .one(of: [alphanum, mark])

private let schemeGen = Gen<Character>.one(of: [
    alpha,
    digit,
    Gen.pure("+"),
    Gen.pure("-"),
    Gen.pure(".")
    ]).proliferateNonEmpty
    .map({ String.init($0) })
    .suchThat({
        $0.unicodeScalars.first.map({ CharacterSet.lowercaseLetters.contains($0) }) ?? false
    })

private let hostname = Gen<Character>.one(of: [
    alphanum,
    Gen.pure("-"),
    ]).proliferateNonEmpty.map({ String.init($0) })
private let tld = alpha
    .proliferateNonEmpty
    .suchThat({ $0.count > 1 })
    .map({ String.init($0) })
private let hostGen = glue(parts: [hostname, Gen.pure("."), tld])

private let portGen = Gen<Int?>.frequency([
    (1, Gen<Int?>.pure(nil)),
    (3, Int.arbitrary.map({ abs($0) }).map(Optional.some))
])

private let pathPartGen: Gen<String> = Gen<Character>.one(of: [
    alpha,
    Gen.pure("/")
    ]).proliferateNonEmpty
    .map({ "/" + String.init($0) })

extension URLComponents : Arbitrary {
    public static var arbitrary: Gen<URLComponents> {
        var components = URLComponents()
        components.scheme = schemeGen.generate
        components.host = hostGen.generate
        components.port = portGen.generate
        components.path = pathPartGen.generate
        return Gen.pure(components)
    }
}

extension URL : Arbitrary {
    public static var arbitrary: Gen<URL> {
        return URLComponents.arbitrary
            .suchThat({ $0.url != nil })
            .map({ $0.url! })
    }
}
