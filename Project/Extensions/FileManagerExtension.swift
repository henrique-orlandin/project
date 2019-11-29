//
//  FileManager.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-26.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

extension FileManager {
    static var directoryURL: URL {
        return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
