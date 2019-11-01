//
//  BandTableViewCell.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-25.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandTableViewCell: UITableViewCell {

    @IBOutlet weak var bandNameLabel: UILabel!
    @IBOutlet weak var bandGenreLabel: UILabel!
    @IBOutlet weak var bandLocationButton: UIButton!
    @IBOutlet weak var bandImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bandCellFormat(band: BandViewModel) {
        self.bandNameLabel.text = band.name
        self.bandImage.load(url: URL(string: band.image)!)
        
        
        self.bandGenreLabel.text = "Genres: \(band.genre)"
        
        let address = [band.location]
//        if let state = band.address.state {
//            address.append(state)
//        } else {
//            address.append(band.address.country)
//        }
        self.bandLocationButton.setTitle("\(address.joined(separator: " - "))", for: .normal)
    }
}
