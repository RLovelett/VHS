//
//  TrackContentTypeTests.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
import SwiftCheck
@testable import VHS
import XCTest

/// MARK: - Generating Arbitrary Headers

private func glue(parts: [Gen<String>]) -> Gen<String> {
    return sequence(parts).map { $0.reduce("", +) }
}

private let topTypes = Gen<Character>.fromElements(of: [
    "application",
    "audio",
    "example",
    "image",
    "message",
    "model",
    "multipart",
    "video",
])

private let subTypes = Gen<Character>.fromElements(of: [
    "x-www-form-urlencoded",
    "form-data",
    "html",
    "png",
    "H264",
    "mp4",
    "mpv",
    "DII",
    "DCD",
    "http",
    "example",
    "global",
])

private let charsets = Gen<Character>.fromElements(of: [
    "UTF-8",
    "UTF-16",
    "UTF-32",
    "ISO-8859-8",
    "ISO-8859-1",
]).map({ ";charset=\($0)" })

private let slash = Gen.pure("/")

private let arbitraryMimeTypes = Gen<String>.frequency([
    (1, glue(parts: [topTypes, slash, subTypes]).map({ $0.randomizeCase() })),
    (1, glue(parts: [topTypes, slash, subTypes, charsets]).map({ $0.randomizeCase() })),
])

private let arbitraryTextMimeTypes = Gen<String>.frequency([
    (1, glue(parts: [Gen.pure("text"), slash, subTypes]).map({ $0.randomizeCase() })),
    (1, glue(parts: [Gen.pure("text"), slash, subTypes, charsets]).map({ $0.randomizeCase() })),
])

private let arbitraryJSONMimeTypes = Gen<String>.frequency([
    (1, Gen.pure("application/json").map({ $0.randomizeCase() })),
    (1, glue(parts: [Gen.pure("application/json"), charsets]).map({ $0.randomizeCase() })),
])

private let arbitraryContentType = Gen<String>.pure("Content-Type").map({ $0.randomizeCase() })

/// MARK: - Generating Arbitrary JSON

private let arbitraryBooleanJSON = Gen<JSON>.compose(build: { (composer) in JSON.bool(composer.generate()) })

private let arbitraryStringJSON = Gen<JSON>.compose(build: { (composer) in
    let str: String = composer.generate()
    let base64 = (str.data(using: .utf8)?.base64EncodedString())
        ?? "SGVsbG8sIG15IG5hbWUgaXMgUnlhbiBMb3ZlbGV0dA0K"
    return JSON.string(base64)
})

private let arbitraryObjectJSON = Gen<JSON>.compose(build: { (composer) in
    let str = String.arbitrary.suchThat { !$0.isEmpty }
    let dictionary: [ String : JSON ] = [
        str.generate: JSON.string(composer.generate()),
        str.generate: JSON.bool(composer.generate()),
    ]
    return JSON.object(dictionary)
})

private let arbitraryJSON = Gen<JSON>.frequency([
    (1, Gen.pure(JSON.null)),
    (1, arbitraryBooleanJSON),
    (2, arbitraryStringJSON),
    (2, arbitraryObjectJSON),
])

extension JSON : Arbitrary {
    public static var arbitrary: Gen<JSON> = Gen<JSON>.compose { composer in
        return JSON.bool(composer.generate())
    }
}

final class TrackContentTypeTests: XCTestCase {

    func testTextBasedContentTypes() {
        property("Generated content types based on text.") <- forAll(arbitraryContentType, arbitraryTextMimeTypes, arbitraryJSON) { (contentType, mimeType, data) in
            // swiftlint:disable:previous line_length
            let header = [ contentType: mimeType ]
            let type = Track.ContentType(from: header)

            switch data {
            case .string:
                return type == .text && type.decode(body: data) != nil
            default:
                return type == .text && type.decode(body: data) == nil
            }
        }
    }

    func testJSONBasedContentTypes() {
        property("Generated content types based on JSON.") <- forAll(arbitraryContentType, arbitraryJSONMimeTypes, arbitraryObjectJSON) { (contentType, mimeType, data) in
            // swiftlint:disable:previous line_length
            let header = [ contentType: mimeType ]
            let type = Track.ContentType(from: header)

            switch data {
            default:
                return type == .json && type.decode(body: data) != nil
            }
        }
    }

    func testBase64ContentTypes() {
        property("Unmatched content types are base64 encoded.") <- forAll(arbitraryContentType, arbitraryMimeTypes, arbitraryJSON) { (contentType, mimeType, data) in
            // swiftlint:disable:previous line_length
            let header = [ contentType: mimeType ]
            let type = Track.ContentType(from: header)

            switch data {
            case .string:
                return type == .base64 && type.decode(body: data) != nil
            default:
                return type == .base64 && type.decode(body: data) == nil
            }
        }
    }

}
