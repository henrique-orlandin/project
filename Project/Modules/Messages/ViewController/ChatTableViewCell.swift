//
//  ChatTableViewCell.swift
//  Jam
//
//  Created by Henri on 2020-02-05.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    var provider: ChatListProvider! = nil
    
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    @IBOutlet weak var lastMessageContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.provider = ChatListProvider()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        chatImage.image = nil
    }
    
    func cellFormat(chat: ChatListViewModel) {
        
        if let band = chat.band {
            name.text = band.name
            provider.loadImage(image: band.image, to: chatImage, ofType: "bands")
        } else if let user = chat.user {
            name.text = user.name
            if let image = user.image {
                provider.loadImage(image: image, to: chatImage, ofType: "users")
            }
        }
        
        if let lastMessage = chat.lastMessage {
            lastMessageDate.text = lastMessage.sent?.timeAgoDisplay()
            lastMessageContent.text = lastMessage.content
        } else {
            lastMessageDate.text = nil
            lastMessageContent.text = nil
        }
            
        chatImage.layer.cornerRadius = chatImage.frame.height / 2;
        chatImage.layer.masksToBounds = true;
    }
}
