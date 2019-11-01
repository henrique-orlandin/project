//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class User: Decodable {
    var name: String
    var email: String
    var address: Address?
    var reviews: [Review]?
    var bands: [Band]?
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}
