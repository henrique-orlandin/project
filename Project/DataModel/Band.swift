//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct Band: Equatable {
    static func == (lhs: Band, rhs: Band) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var name: String
    var image: String
    var description: String
    var genres: [Genre]
    var location: Location
    var gallery: [String]?
    var reviews: [Review]?
    var contact: [String]?
    var videos: [String]?
    var audios: [String]?
    var links: [String]?
    var musicians: [Musician]?
    var advertising: Bool = false
    
}
