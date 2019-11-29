//
//  ArrayExtension.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-29.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

extension Array where Element == Band {
    init(jsonData data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode([Band].self, from: data)
    }
}
