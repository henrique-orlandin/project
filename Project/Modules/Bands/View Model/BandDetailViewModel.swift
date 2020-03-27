//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct BandDetailViewModel {
    
    var id: String
    var name: String
    var genre: String
    var image: String
    var location: String
    var description: String
    var user: User?
    
    init(_ band: Band, user: User?) {
        
        self.id = band.id
        self.image = band.image
        
        self.genre = band.genres.map {$0.rawValue}.joined(separator: ", ")
        self.name = band.name
        
        var location = [String]()
        if let city = band.location.city {
            location.append(city)
        }
        if let state = band.location.state {
            location.append(state)
        }
        if let country = band.location.country {
            location.append(country)
        }
        
        self.location = location.joined(separator: ", ")
        
        self.description = band.description
        self.user = user
    }
}
