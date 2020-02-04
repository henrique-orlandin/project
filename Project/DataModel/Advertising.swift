//
//  Musician.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct Advertising: Equatable {
    
    static func == (lhs: Advertising, rhs: Advertising) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var type: AdType
    var notify: Bool
    var id_user: String?
    var id_band: String?
    var user: User?
    var band: Band?
    var genre: [Genre]?
    var skills: [Skills]?
    var location: Location?
    
    enum AdType {
        case band
        case musician
    }
}
