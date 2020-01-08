//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct Location: Decodable {
    var city: String?
    var state: String?
    var country: String?
    var postalCode: String?
    var lat: Double
    var lng: Double
    
}
