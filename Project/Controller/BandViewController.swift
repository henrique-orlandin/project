//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandViewController: UIViewController {

    var band: Band?
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let band = self.band {
            title = band.name
            let genres = band.genres.map({
                $0.rawValue
            })
            imageView.load(url: URL(string: band.pictures[0])!)
            genreLabel.text = "\(genres.joined(separator: ", "))"
            var address = [band.address.city]
            if let state = band.address.state {
                address.append(state)
            } else {
                address.append(band.address.country)
            }
            locationButton.setTitle("\(address.joined(separator: " - "))", for: .normal)
        }
    }
}
