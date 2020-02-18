//
//  BandTableViewCell.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-25.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class MusiciansTableViewCell: UITableViewCell {
    var provider: MusiciansListProvider! = nil
    
    @IBOutlet weak var musicianImage: UIImageView!
    @IBOutlet weak var musicianNameLabel: UILabel!
    @IBOutlet weak var musicianGenreLabel: UILabel!
    @IBOutlet weak var musicianSkillsLabel: UILabel!
    @IBOutlet weak var musicianLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.provider = MusiciansListProvider()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        musicianImage.image = nil
    }
    
    func musicianCellFormat(user: MusiciansListViewModel) {
        musicianNameLabel.text = user.name
        
        musicianGenreLabel.text = user.genre
        musicianSkillsLabel.text = user.skills
        musicianLocationLabel.text = user.location
        
        musicianImage.layer.cornerRadius = 5.0;
        musicianImage.layer.masksToBounds = true;
        
        if let image = user.image {
            provider.loadImage(image: image, to: musicianImage)
        }
    }
}
