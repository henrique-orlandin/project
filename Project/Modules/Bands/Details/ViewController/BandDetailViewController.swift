//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandDetailViewController: UIViewController {
    
    var id: String?
    var provider: BandDetailProvider!
     
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = BandDetailProvider()
        self.provider.delegate = self
        do {
            try self.provider.loadBand(self.id!)
        } catch {
            print(error)
        }
        
    }
    
}

extension BandDetailViewController: BandDetailProviderProtocol {
    func providerDidLoadImage(provider of: BandDetailProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            imageView.image = UIImage(data: data)
        }
    }
    
    func providerDidFinishLoading(provider of: BandDetailProvider, band: BandDetailViewModel?) {
        
        if let band = band {
            title = band.name
            self.nameLabel.text = band.name
             
            genreLabel.text = "\(band.genre)"
            descriptionText.text = "\(band.description)"
            locationLabel.text = "\(band.location)"
            
            imageView.layer.cornerRadius = 5.0;
            imageView.layer.masksToBounds = true;
            
            provider.loadImage(image: band.image, to: imageView)
        }
    }
} 
