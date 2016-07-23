//
//  Argo+JSON+Test+Helpers.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/12/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
import Foundation

// Idea taken from Venmo/DVR/Vinyl (thanks!)
private func testingBundle() -> Bundle? {
    let bundleArray = Bundle.allBundles.filter() { $0.bundlePath.hasSuffix(".xctest") }
    guard bundleArray.count == 1 else { return nil }
    return bundleArray.first
}

extension JSON {
    init?(
        contentsOfString string: Swift.String,
        options: JSONSerialization.ReadingOptions = JSONSerialization.ReadingOptions(rawValue: 0)
    ) {
        guard let json = string.data(using: Swift.String.Encoding.utf8)
            .flatMap({ try? JSONSerialization.jsonObject(with: $0, options: options) })
            .flatMap({ JSON($0) })
        else { return nil }
        self = json
    }

    init?(
        contentsOfURL url: URL,
        options: JSONSerialization.ReadingOptions = JSONSerialization.ReadingOptions(rawValue: 0)
    ) {
        guard let json = (try? Data(contentsOf: url))
            .flatMap({ try? JSONSerialization.jsonObject(with: $0, options: options) })
            .flatMap({ JSON($0) })
        else { return nil }
        self = json
    }

    init?(
        withName: Swift.String,
        fromBundle bundle: Bundle? = testingBundle(),
        options: JSONSerialization.ReadingOptions = JSONSerialization.ReadingOptions(rawValue: 0)
    ) {
        guard let json = bundle?.url(forResource: withName, withExtension: "json")
            .flatMap({ try? Data(contentsOf: $0) })
            .flatMap({ try? JSONSerialization.jsonObject(with: $0, options: options) })
            .flatMap({ JSON($0) })
        else { return nil }
        self = json
    }
}
