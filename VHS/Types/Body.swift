//
//  Body.swift
//  VHS
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

public struct Body: Decodable {

    enum Keys: String, CodingKey {
        case type
        case data
    }

    private let raw: BodyDataDecodable?
    public let data: Data?

    init(_ data: Data?) {
        self.raw = nil
        self.data = data
    }

    init<T: BodyDataDecodable>(_ raw: T) {
        self.raw = raw
        self.data = self.raw?.data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try? container.decode(String.self, forKey: .type)

        if Text.handle(type) {
            self.init(try container.decode(Text.self, forKey: .data))
        } else if JSON.handle(type) {
            self.init(try container.decode(JSON.self, forKey: .data))
        } else {
            self.init(try container.decode(Base64.self, forKey: .data))
        }
    }

}
