//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import FirebaseAuth

class MusiciansDetailViewController: UIViewController {
    
    var id: String?
    var provider: MusiciansDetailProvider!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    
    
    @IBAction func chat(_ sender: Any) {
        provider.chat(id: id!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = MusiciansDetailProvider()
        self.provider.delegate = self
        do {
            self.view.showSpinner(onView: self.view)
            try self.provider.loadUser(self.id!)
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
    
}

extension MusiciansDetailViewController: MusiciansDetailProviderProtocol {
    func providerDidLoadImage(provider of: MusiciansDetailProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            imageView.image = UIImage(data: data)
        }
    }
    
    func providerDidFinishLoading(provider of: MusiciansDetailProvider, musician: MusiciansDetailViewModel?) {
        
        if let musician = musician {
            
            self.nameLabel.text = musician.name
            
            genreLabel.text = "\(musician.genre)"
            skillsLabel.text = "\(musician.skills)"
            descriptionText.text = "\(musician.description)"
            locationLabel.text = "\(musician.location)"
            
            
            if let image = musician.image { 
                provider.loadImage(image: image, to: imageView)
            } else {
                let icon = UIImage.fontAwesomeIcon(name: .microphoneAlt, style: .solid, textColor: UIColor(rgb: 0x222222), size: CGSize(width: 150, height: 150))
                imageView.image = icon
                imageView.contentMode = .center
            }
            
            if Auth.auth().currentUser == nil || Auth.auth().currentUser!.uid == musician.id {
                chatButton.isHidden = true
            }
            self.view.removeSpinner()
        }
    }
    
    func providerDidFindChat(provider of: MusiciansDetailProvider, chatId: String) {
        let storyboard = UIStoryboard(name: "Messages", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "messageListVC") as! MessageListViewController
        vc.chat_id = chatId
        navigationController?.pushViewController(vc, animated: true)
    }
}
