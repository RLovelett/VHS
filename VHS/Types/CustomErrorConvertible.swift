//
//  CustomErrorConvertible.swift
//  VHS
//
//  Created by Ryan Lovelett on 6/24/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

/// - SeeAlso: [Convert ErrorProtocol to NSError](http://stackoverflow.com/a/33307946/247730)
protocol CustomErrorConvertible: Error {
    func userInfo() -> [String: String]?
    func domain() -> String
    func code() -> Int
}

extension CustomErrorConvertible {

    func error() -> NSError {
        return NSError(domain: self.domain(), code: self.code(), userInfo: self.userInfo())
    }

}
