//
//  BandTableViewCell.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-25.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

protocol MyBandCollectionViewCellDelegate: class {
    func removeCell(_ controller: MyBandCollectionViewCell, band: Band?)
}

class MyBandCollectionViewCell: UICollectionViewCell {
    
    var provider: MyBandListProvider! = nil
    var band: Band?
    weak var delegate: MyBandCollectionViewCellDelegate? 

    @IBOutlet weak var bandImage: UIImageView!
    @IBOutlet weak var bandNameLabel: UILabel!
    @IBOutlet weak var bandGenreLabel: UILabel!	
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var checkMark: UIButton!
    
    var isInEditingMode: Bool = false {
        didSet {
            self.checkMark.isHidden = !isInEditingMode
            self.backgroundCellView.layer.borderWidth = isInEditingMode ? 2 : 0
            self.backgroundCellView.layer.borderColor = isInEditingMode ? UIColor(rgb: 0x222222).cgColor : .none
        }
    }
    
    @IBAction func removeItem(_ sender: Any) {
        delegate?.removeCell(self, band: band)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.provider = MyBandListProvider()
        self.provider.delegate = self
    }

    override func prepareForReuse() {
        bandImage.image = nil
    }
    
    func bandCellFormat(band: MyBandListViewModel) {
        
        self.bandNameLabel.text = band.name
        self.bandGenreLabel.text = "\(band.genre)"
        self.locationLabel.text = "\(band.location)"
        self.checkMark.isHidden = true
        
        bandImage.rounded()
        bandImage.loading()
        backgroundCellView.collectionViewCellLayout()
        
        provider.loadImage(image: band.image, to: bandImage)
        
        let icon = UIImage.fontAwesomeIcon(name: .trash, style: .solid, textColor: .white, size: CGSize(width: 18, height: 18))
        checkMark.setImage(icon, for: .normal)
        checkMark.defaultLayout()
        checkMark.layer.cornerRadius = checkMark.frame.height / 2
    }
}

extension MyBandCollectionViewCell: MyBandListProviderProtocol {
    func providerDidLoadImage(provider of: MyBandListProvider, image: UIImage, imageView: UIImageView) {
        imageView.image = image
        imageView.loaded()
    }
}
