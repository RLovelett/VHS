//
//  Text.swift
//  VHS
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

struct Text: BodyDataDecodable {
    static func handle(_ contentType: String?) -> Bool {
        return contentType?.lowercased().hasPrefix("text/") ?? false
    }

    private let raw: String?
    let data: Data?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.raw = try container.decode(String.self)
        self.data = self.raw?.data(using: .utf8)
    }
}
