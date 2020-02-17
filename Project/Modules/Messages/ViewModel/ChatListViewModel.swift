//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct ChatListViewModel {
    
    var id: String
    var user: User?
    var band: Band?
    var lastMessage: Message?
    
    init(_ chat: Chat) {
        self.id = chat.id
        self.user = chat.user
        self.band = chat.band
        self.lastMessage = chat.lastMessage
    }
}
