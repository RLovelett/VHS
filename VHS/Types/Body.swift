//
//  Body.swift
//  VHS
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

struct Body: Decodable {

    enum Keys: String, CodingKey {
        case headers
        case body
    }

    private let raw: BodyDataDecodable?
    let data: Data?

    init<T: BodyDataDecodable>(_ raw: T) {
        self.raw = raw
        self.data = self.raw?.data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let headers = try container.decode([String: String].self, forKey: .headers)
        let contentType = headers[caseInsensitive: "content-type"]

        if Text.handle(contentType) {
            self.init(try container.decode(Text.self, forKey: .body))
        } else if JSON.handle(contentType) {
            self.init(try container.decode(JSON.self, forKey: .body))
        } else {
            self.init(try container.decode(Base64.self, forKey: .body))
        }
    }

}

