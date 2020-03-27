//
//  BandTableViewCell.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-25.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class MusiciansCollectionViewCell: UICollectionViewCell {
    var provider: MusiciansListProvider! = nil
    
    @IBOutlet weak var musicianImage: UIImageView!
    @IBOutlet weak var musicianNameLabel: UILabel!
    @IBOutlet weak var musicianGenreLabel: UILabel!
    @IBOutlet weak var musicianSkillsLabel: UILabel!
    @IBOutlet weak var musicianLocationLabel: UILabel!
    @IBOutlet weak var backgroundCellView: UIView!
    @IBOutlet weak var arrowLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.provider = MusiciansListProvider()
        self.provider.delegate = self
    }

    override func prepareForReuse() {
        musicianImage.image = nil
    }
    
    func musicianCellFormat(user: MusiciansListViewModel) {
        
        arrowLabel.font = UIFont.fontAwesome(ofSize: 20, style: .solid)
        arrowLabel.text = String.fontAwesomeIcon(name: .angleRight)
        
        backgroundCellView.collectionViewCellLayout()
        musicianNameLabel.text = user.name
        
        musicianGenreLabel.text = user.genre
        musicianSkillsLabel.text = user.skills
        musicianLocationLabel.text = user.location
        
        musicianImage.rounded()
        
        if let image = user.image {
            musicianImage.loading()
            provider.loadImage(image: image, to: musicianImage)
        } else {
            let icon = UIImage.fontAwesomeIcon(name: .microphoneAlt, style: .solid, textColor: UIColor(rgb: 0x222222), size: CGSize(width: 60, height: 60))
            musicianImage.image = icon
            musicianImage.contentMode = .center
        }
    }
}

extension MusiciansCollectionViewCell: MusiciansListProviderProtocol {
    func providerDidLoadImage(provider of: MusiciansListProvider, image: UIImage, imageView: UIImageView) {
        musicianImage.image = image
        musicianImage.loaded()
    }
}
