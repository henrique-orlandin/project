//
//  Genre.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

enum Genre: String, Decodable, CaseIterable {
    case alternative = "Alternative"
    case blues = "Blues"
    case classical = "Classical"
    case country = "Country"
    case dance = "Dance"
    case electronic = "Electronic"
    case folk = "Folk"
    case grunge = "Grounge"
    case hiphop = "Hip-Hop"
    case indie = "Indie"
    case industrial = "Industrial"
    case gospel = "Gospel"
    case jazz = "Jazz"
    case latin = "Latin"
    case metal = "Metal"
    case pop = "Pop"
    case punk = "Punk"
    case rap = "Rap"
    case reggae = "Reggae"
    case rock = "Rock"
    case soul = "Soul"
    case other = "Other"
}
