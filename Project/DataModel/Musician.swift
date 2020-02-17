//
//  Musician.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct Musician {
    var description: String
    var genres: [Genre]
    var skills: [Skills]
    var gallery: [String]?
    var reviews: [Review]?
    var contact: [String]?
    var videos: [String]?
    var audios: [String]?
    var links: [String]?
    var advertising: Bool = false
}
