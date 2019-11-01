//
//  ArrayExtension.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-29.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

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
