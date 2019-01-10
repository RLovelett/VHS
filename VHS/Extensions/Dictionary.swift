//
//  Dictionary.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

extension Dictionary where Key == String {
    subscript(caseInsensitive key: Key) -> Value? {
        if let matchedKey = keys.first(where: { $0.caseInsensitiveCompare(key) == .orderedSame }) {
            return self[matchedKey]
        }
        return nil
    }
}
