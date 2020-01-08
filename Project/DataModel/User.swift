//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class User: Decodable {
    var id: Int
    var name: String
    var email: String
    var location: Location?
    var reviews: [Review]?
    
    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
