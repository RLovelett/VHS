//
//  Base64.swift
//  VHS
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

struct Base64: BodyDataDecodable {
    static func handle(_ contentType: String?) -> Bool {
        return contentType == nil
    }

    let data: Data?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.data = try container.decode(Data.self)
    }
}
