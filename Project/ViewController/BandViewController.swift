//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandViewController: UIViewController {

    var band: BandViewModel?
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let band = self.band {
            title = band.name
            imageView.load(url: URL(string: band.image)!)
            genreLabel.text = "\(band.genre)"
            locationButton.setTitle("\(band.location)", for: .normal)
        }
    }
}
