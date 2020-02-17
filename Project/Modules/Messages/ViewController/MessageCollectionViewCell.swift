//
//  MessageCollectionViewCell.swift
//  Jam
//
//  Created by Henri on 2020-02-06.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//

import UIKit
import FirebaseAuth

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var content: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        content.text = nil
        content.backgroundColor = UIColor.link
        content.textColor = UIColor.white
    }

    func cellFormat(message: MessageListViewModel) {
        
        content.text = message.content
        
        let size = CGSize(width: 250, height: CGFloat(MAXFLOAT))
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: message.content!).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], context: nil)
        
        content.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let newSize: CGSize = content.sizeThatFits(CGSize(width: estimatedFrame.width + 80, height: CGFloat(MAXFLOAT)))
        var newFrame = content.frame
        
        var x: CGFloat = 20
        if message.sender == Auth.auth().currentUser?.uid {
            x = self.frame.width - newSize.width - 20
        } else {
            content.backgroundColor = UIColor(rgb: 0xCCCCCC, a: 0.6)
            content.textColor = UIColor(rgb: 0x222222)
        }
        
        newFrame = CGRect(x: x, y: 0, width: newSize.width, height: newSize.height)
        content.frame = newFrame
        content.layer.cornerRadius = 15
        content.layer.masksToBounds = true
    }
    
}
