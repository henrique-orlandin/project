//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct MusiciansDetailViewModel {
    
    var id: String
    var name: String
    var genre: String
    var skills: String
    var image: String?
    var location: String
    var description: String
    
    init(_ user: User) {
        
        self.id = user.id
        self.image = user.image
        
        self.genre = user.musician!.genres.map {$0.rawValue}.joined(separator: ", ")
        self.skills = user.musician!.skills.map {$0.rawValue}.joined(separator: ", ")
        self.name = user.name
        
        var location = [String]()
        if let city = user.location!.city {
            location.append(city)
        }
        if let state = user.location!.state {
            location.append(state)
        }
        if let country = user.location!.country {
            location.append(country)
        }
        
        self.location = location.joined(separator: ", ")
        
        self.description = user.musician!.description
    }
}
