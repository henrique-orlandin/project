//
//  BandTableViewCell.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-25.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class MyAdsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var lookingForLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func adCellFormat(ad: MyAdsListViewModel) {
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
