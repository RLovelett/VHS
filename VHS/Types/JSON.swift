//
//  JSON.swift
//  VHS
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

struct JSON: BodyDataDecodable {
    static func handle(_ contentType: String?) -> Bool {
        return contentType?.lowercased().hasPrefix("application/json") ?? false
    }

    private let raw: AnyCodable?
    let data: Data?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.raw = try container.decode(AnyCodable.self)

        // TODO: There is so much wasted code because of the parsing of JSON body. All we really want is the raw
        // undecoded bytes of the body. Unfortunately the only API available requires us to decode it to a Swift type
        // (here AnyCodable) and then back to a Data. Wasted processing. Excess code.
        let encoder = JSONEncoder()
        self.data = try self.raw.map { try encoder.encode($0) }
    }
}
