//
//  ChatTableViewCell.swift
//  Jam
//
//  Created by Henri on 2020-02-05.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//

import UIKit

class ChatCollectionViewCell: UICollectionViewCell {

    var provider: ChatListProvider! = nil
    
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastMessageDate: UILabel!
    @IBOutlet weak var lastMessageContent: UILabel!
    @IBOutlet weak var backgroundCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.provider = ChatListProvider()
        self.provider.delegate = self
    }
    
    override func prepareForReuse() {
        chatImage.image = nil
    }
    
    func cellFormat(chat: ChatListViewModel) {
        
        backgroundCellView.collectionViewCellLayout()
        
        chatImage.rounded()
        if let band = chat.band {
            name.text = band.name
            provider.loadImage(image: band.image, to: chatImage, ofType: "bands")
            chatImage.loading()
        } else if let user = chat.user {
            name.text = user.name
            if let image = user.image {
                provider.loadImage(image: image, to: chatImage, ofType: "users")
                chatImage.loading()
            } else {
                let icon = UIImage.fontAwesomeIcon(name: .microphoneAlt, style: .solid, textColor: UIColor(rgb: 0x222222), size: CGSize(width: 40, height: 40))
                chatImage.image = icon
                chatImage.contentMode = .center
            }
        }
        
        if let lastMessage = chat.lastMessage {
            lastMessageDate.text = lastMessage.sent?.timeAgoDisplay()
            lastMessageContent.text = lastMessage.content
        } else {
            lastMessageDate.text = nil
            lastMessageContent.text = nil
        }
            
    }
}

extension ChatCollectionViewCell: ChatListProviderProtocol {
    func providerDidLoadImage(provider of: ChatListProvider, image: UIImage, imageView: UIImageView) {
        chatImage.image = image
        chatImage.loaded()
    }
}
