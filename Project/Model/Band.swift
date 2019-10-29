//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct Band: Decodable {
    var name: String
    var description: String
    var pictures: [String]
    var genres: [Genre]
    var address: Address
    var reviews: [Review]?
    var contact: [String]?
    var videos: [String]?
    var audios: [String]?
    var links: [String]?
    var musicians: [Musician]?
    
    enum DecodingError: Error {
        case missingFile
    }
    
    init(name: String, description: String, pictures: [String], genres: [Genre], address: Address) {
        self.name = name
        self.description = description
        self.pictures = pictures
        self.genres = genres
        self.address = address
    }
}

extension Array where Element == Band {
    init(fileName: String) throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw Band.DecodingError.missingFile
        }
        
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self = try decoder.decode([Band].self, from: data)
    }
}
