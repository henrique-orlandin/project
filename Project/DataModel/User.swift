//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class User {
    var id: String
    var name: String
    var image: String?
    var location: Location?
    var musician: Musician?
    
    init(id: String, name: String, image: String?, location: Location?, musician: Musician?) {
        self.id = id
        self.name = name
        self.image = image
        self.location = location
        self.musician = musician
    }
}
