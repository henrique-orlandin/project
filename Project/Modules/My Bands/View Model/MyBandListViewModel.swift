//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct MyBandListViewModel: Decodable {
    
    var id: String
    var image: String
    var name: String
    var genre: String
    var location: String
    
    init(_ band: Band) {
        
        self.id = band.id
        
        self.image = band.image
        
        self.name = band.name
        self.genre = band.genres.map {$0.rawValue}.joined(separator: ", ")
        
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
    }
}
