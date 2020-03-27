//
//  BandTableViewCell.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-25.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandCollectionViewCell: UICollectionViewCell {
    var provider: BandListProvider! = nil
    
    @IBOutlet weak var bandImage: UIImageView!
    @IBOutlet weak var bandNameLabel: UILabel!
    @IBOutlet weak var bandGenreLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var arrowLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.provider = BandListProvider()
        self.provider.delegate = self
    }
    
    override func prepareForReuse() {
        bandImage.image = nil
        bandImage.loading()
    }
    
    func bandCellFormat(band: BandListViewModel) {
        
        arrowLabel.font = UIFont.fontAwesome(ofSize: 20, style: .solid)
        arrowLabel.text = String.fontAwesomeIcon(name: .angleRight)
        
        backgroundCellView.collectionViewCellLayout()
        
        bandNameLabel.text = band.name
        bandGenreLabel.text = band.genre
        locationLabel.text = band.location
        
        bandImage.rounded()
        bandImage.loading()
        
        provider.loadImage(image: band.image, to: bandImage)
    }
}

extension BandCollectionViewCell: BandListProviderProtocol {
    func providerDidLoadImage(provider of: BandListProvider, image: UIImage, imageView: UIImageView) {
        imageView.image = image
        imageView.loaded()
    }
}
