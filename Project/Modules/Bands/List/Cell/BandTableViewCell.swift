//
//  BandTableViewCell.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-25.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandTableViewCell: UITableViewCell {
    var provider: MyBandListProvider! = nil
    
    @IBOutlet weak var bandImage: UIImageView!
    @IBOutlet weak var bandNameLabel: UILabel!
    @IBOutlet weak var bandGenreLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.provider = MyBandListProvider()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        bandImage.image = nil
    }
    
    func bandCellFormat(band: BandListViewModel) {
        bandNameLabel.text = band.name
        
        bandGenreLabel.text = band.genre
        locationLabel.text = band.location
        
        bandImage.layer.cornerRadius = 5.0;
        bandImage.layer.masksToBounds = true;
        
        provider.loadImage(image: band.image, to: bandImage)
    }
}
