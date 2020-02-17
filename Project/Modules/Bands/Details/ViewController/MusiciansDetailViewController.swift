//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class MusiciansDetailViewController: UIViewController {
    
    var id: String?
    var provider: MusiciansDetailProvider!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = MusiciansDetailProvider()
        self.provider.delegate = self
        do {
            try self.provider.loadUser(self.id!)
        } catch {
            print(error)
        }
        
    }
    
}

extension MusiciansDetailViewController: MusiciansDetailProviderProtocol {
    func providerDidLoadImage(provider of: MusiciansDetailProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            imageView.image = UIImage(data: data)
        }
    }
    
    func providerDidFinishLoading(provider of: MusiciansDetailProvider, musician: MusiciansDetailViewModel?) {
        
        if let musician = musician {
            title = musician.name
            self.nameLabel.text = musician.name
            
            genreLabel.text = "\(musician.genre)"
            skillsLabel.text = "\(musician.skills)"
            descriptionText.text = "\(musician.description)"
            locationLabel.text = "\(musician.location)"
            
            imageView.layer.cornerRadius = 5.0;
            imageView.layer.masksToBounds = true;
            
            if let image = musician.image { 
                provider.loadImage(image: image, to: imageView)
            }
        }
    }
}
