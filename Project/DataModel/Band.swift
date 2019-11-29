//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct Band: Equatable, Decodable {
    static func == (lhs: Band, rhs: Band) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var name: String
    var description: String
    var pictures: [String]
    var genres: [Genre]
    var address: Address
    var reviews: [Review]?
    var contact: [String]?
    var videos: [String]?
    var audios: [String]?
    var links: [String]?
    var musicians: [Musician]?
}
