//
//  HTTPURLResponse.swift
//  VHS
//
//  Created by Ryan Lovelett on 7/18/16.
//  Copyright © 2016 Ryan Lovelett. All rights reserved.
//

import Foundation

extension HTTPURLResponse {

    convenience init?(using track: Track.Response) {
        guard let statusCode = track.statusCode else { return nil }
        self.init(url: track.url,
                  statusCode: statusCode,
                  httpVersion: "HTTP/1.1",
                  headerFields: track.headers)
    }

}
