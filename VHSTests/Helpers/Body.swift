//
//  Body.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

@testable import VHS

struct MockBody: BodyDataDecodable {
    static func handle(_ contentType: String?) -> Bool {
        fatalError("Intentionally left blank")
    }

    let data: Data?

    init(_ string: String) {
        self.data = string.data(using: .utf8)
    }

    init(_ data: Data?) {
        self.data = data
    }
}

extension Body {
    var string: String? {
        return self.data.flatMap { String(data: $0, encoding: .utf8) }
    }
    var base64: String? {
        return self.data?.base64EncodedString()
    }
}
