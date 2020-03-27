//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import FirebaseAuth

class BandDetailViewController: UIViewController {
    
    var id: String?
    var provider: BandDetailProvider!
     
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    
    
    @IBAction func chat(_ sender: Any) {
        provider.chat()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = BandDetailProvider()
        self.provider.delegate = self
        do {
            self.view.showSpinner(onView: self.view)
            try self.provider.loadBand(self.id!)
        } catch {
            print(error)
        }
        
        let icon = UIImage.fontAwesomeIcon(name: .comment, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
        chatButton.setImage(icon, for: .normal)
        chatButton.defaultLayout()
        chatButton.layer.cornerRadius = chatButton.frame.height / 2
        
        descriptionText.textContainer.lineFragmentPadding = 0
        descriptionText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
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
            
            self.nameLabel.text = band.name
             
            genreLabel.text = "\(band.genre)"
            descriptionText.text = "\(band.description)"
            locationLabel.text = "\(band.location)"
            
            provider.loadImage(image: band.image, to: imageView)
            self.view.removeSpinner()
            
            if Auth.auth().currentUser == nil || Auth.auth().currentUser!.uid == band.user!.id {
                chatButton.isHidden = true
            }
        }
    }
    func providerDidFindChat(provider of: BandDetailProvider, chatId: String) {
        let storyboard = UIStoryboard(name: "Messages", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "messageListVC") as! MessageListViewController
        vc.chat_id = chatId
        navigationController?.pushViewController(vc, animated: true)
    }
} 
