//
//  BandTableViewCell.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-25.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

protocol MyAdsCollectionViewCellDelegate: class {
    func removeCell(_ controller: MyAdsCollectionViewCell, ad: Advertising?)
}

class MyAdsCollectionViewCell: UICollectionViewCell {
    
    var ad: Advertising?
    weak var delegate: MyAdsCollectionViewCellDelegate?
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var isInEditingMode: Bool = false {
        didSet {
            self.deleteButton.isHidden = !isInEditingMode
            self.backgroundCellView.layer.borderWidth = isInEditingMode ? 2 : 0
            self.backgroundCellView.layer.borderColor = isInEditingMode ? UIColor(rgb: 0x222222).cgColor : .none
        }
    }
    
    @IBAction func removeItem(_ sender: Any) {
        delegate?.removeCell(self, ad: ad)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func adCellFormat(ad: MyAdsListViewModel) {
        
        backgroundCellView.collectionViewCellLayout()
        self.deleteButton.isHidden = true
        
        let icon = UIImage.fontAwesomeIcon(name: .trash, style: .solid, textColor: .white, size: CGSize(width: 18, height: 18))
        deleteButton.setImage(icon, for: .normal)
        deleteButton.defaultLayout()
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
        
        if let type = ad.type {
            if type == Advertising.AdType.band, let band = ad.band {
                targetLabel.text = band.name
                lookingForLabel.text = "Musician"
            } else if type == Advertising.AdType.musician, let user = ad.user {
                targetLabel.text = user.name
                lookingForLabel.text = "Band"
            }
        }
    }
}
