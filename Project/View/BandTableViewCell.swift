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
    
    func bandCellFormat(band: Band) {
        self.bandNameLabel.text = band.name
        self.bandImage.load(url: URL(string: band.pictures[0])!)
        
        let genres = band.genres.map({
            $0.rawValue
        })
        self.bandGenreLabel.text = "Genres: \(genres.joined(separator: ", "))"
        
        var address = [band.address.city]
        if let state = band.address.state {
            address.append(state)
        } else {
            address.append(band.address.country)
        }
        self.bandLocationButton.setTitle("\(address.joined(separator: " - "))", for: .normal)
    }
}
