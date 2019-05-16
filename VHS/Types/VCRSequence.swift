//
//  VCRSequence.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/16/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation

internal protocol VCRSequence {
    init(sequenceOf: [Track], inOrder: VCR.PlaybackSequence)
    mutating func next(for request: Request) -> Track?
}

private func byMatching(_ track: Request, with request: Request) -> (Bool, VCR.PlaybackSequence.MatchType) -> Bool {
    return { (previous: Bool, type: VCR.PlaybackSequence.MatchType) -> Bool in
        return previous && type.match(track, with: request)
    }
}

internal struct LoopingSequence: VCRSequence {

    let tracks: [Track]

    let orderBy: VCR.PlaybackSequence

    var currentIndex: Array<Track>.Index

    init(sequenceOf: [Track], inOrder: VCR.PlaybackSequence) {
        self.tracks = sequenceOf
        self.orderBy = inOrder
        self.currentIndex = sequenceOf.startIndex
    }

    mutating func next(for request: Request) -> Track? {
        switch self.orderBy {
        case .cassetteOrder:
            let track = self.tracks[self.currentIndex]
            self.currentIndex = self.currentIndex.advanced(by: 1)
            if self.currentIndex >= self.tracks.endIndex {
                self.currentIndex = self.tracks.startIndex
            }
            return track
        case .properties(matching: let matchers):
            for track in self.tracks {
                guard matchers.reduce(true, byMatching(track.request, with: request))
                    else { continue }
                return track
            }
            return .none
        }
    }

}

internal struct EphemeralSequence: VCRSequence {

    var tracks: [Track]

    let matchers: [VCR.PlaybackSequence.MatchType]

    init(sequenceOf: [Track], inOrder: VCR.PlaybackSequence) {
        self.tracks = sequenceOf
        switch inOrder {
        case .cassetteOrder:
            self.matchers = []
        case .properties(matching: let matchers):
            self.matchers = matchers
        }
    }

    mutating func next(for request: Request) -> Track? {
        for (offset, track) in self.tracks.enumerated() {
            guard matchers.reduce(true, byMatching(track.request, with: request)) else { continue }
            let index = self.tracks.index(self.tracks.startIndex, offsetBy: offset)
            self.tracks.remove(at: index)
            return track
        }
        return .none
    }

}
