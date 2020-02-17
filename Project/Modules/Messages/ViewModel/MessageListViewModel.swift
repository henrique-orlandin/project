//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct MessageListViewModel {
    
    var id: String
    var sender: String
    var content: String?
    
    init(_ message: Message) {
        self.id = message.id
        self.sender = message.sender
        self.content = message.content
    }
    
}
