//
//  JSON.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/14/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Argo
import Foundation

extension JSON {
    func encode() -> Any {
        switch self {
        case .object(let dictionary):
            var accum = Dictionary<String, Any>(minimumCapacity: dictionary.count)
            for (key, value) in dictionary {
                accum[key] = value.encode()
            }
            return accum
        case .string(let str):
            return str
        default:
            return NSNull()
        }
    }
}
