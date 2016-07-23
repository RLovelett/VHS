//
//  String.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/13/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation

extension String {
    /// This is a variation on the code found from StackOverflow.
    /// - SeeAlso: http://stackoverflow.com/a/27698155/247730
    func isUppercase(at index: Index) -> Bool {
        let range = index..<self.index(after: index)
        return self.rangeOfCharacter(from: .uppercaseLetters, options: [], range: range) != nil
    }

    /// Create a new `String` instance that is a copy of the current
    func uppercased(at index: Index) -> String {
        let str = String(self[index]).uppercased()
        var newStr = self
        newStr.replaceSubrange(index...index, with: str)
        return newStr
    }

    func lowercased(at index: Index) -> String {
        let str = String(self[index]).lowercased()
        var newStr = self
        newStr.replaceSubrange(index...index, with: str)
        return newStr
    }

    func changeCase(at index: Index) -> String {
        if self.isUppercase(at: index) {
            return self.lowercased(at: index)
        } else {
            return self.uppercased(at: index)
        }
    }

    func randomizeCase() -> String {
        let count = Int(arc4random_uniform(UInt32(self.characters.count)))
        let indices = (0..<count).lazy
            .map({ _ in Int(arc4random_uniform(UInt32(self.characters.count))) })
            .map({ self.index(self.startIndex, offsetBy: $0) })
        return indices.reduce(self, { $0.changeCase(at: $1) })
    }
}
