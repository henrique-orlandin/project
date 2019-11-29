//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandViewController: UIViewController {
    
    var band: BandDetailViewModel?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let band = self.band {
            title = band.name
            nameLabel.text = band.name
            imageView.load(url: URL(string: band.image)!)
            genreLabel.text = "\(band.genre)"
            descriptionText.text = "\(band.description)"
            locationLabel.text = "\(band.location)"
            
            imageView.layer.cornerRadius = 5.0;
            imageView.layer.masksToBounds = true;
        }
    }

}
