//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct BandViewModel: Decodable {
    
    var image: String
    var name: String
    var genre: String
    var location: String
    
    init(_ band: Band) {
        self.image = band.pictures[0]
        self.name = band.name
        self.genre = band.genres.map {$0.rawValue}.joined(separator: ", ")
        self.location = band.address.city
    }
}
