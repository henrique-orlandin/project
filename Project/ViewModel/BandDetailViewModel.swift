//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct BandDetailViewModel: Decodable {
    
    var name: String
    var genre: String
    var image: String
    var location: String
    var description: String
    
    init(_ band: Band) {
        self.image = band.pictures[0]
        self.genre = band.genres.map {$0.rawValue}.joined(separator: ", ")
        self.name = band.name
        self.location = band.address.city
        self.description = band.description
    }
}
