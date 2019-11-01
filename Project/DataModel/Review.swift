//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct Review: Decodable {
    var user: User
    var score: Int
    var description: String?
}
