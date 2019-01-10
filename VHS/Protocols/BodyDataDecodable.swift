//
//  BodyDataDecodable.swift
//  VHS
//
//  Created by Lovelett, Ryan A. on 1/10/19.
//  Copyright © 2019 Ryan Lovelett. All rights reserved.
//

protocol BodyDataDecodable: Decodable {
    static func handle(_ contentType: String?) -> Bool
    var data: Data? { get }
}
