//
//  ProfileViewController.swift
//  Jam
//
//  Created by Henri on 2019-12-01.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FontAwesome_swift

class ProfileViewController: UIViewController {

    private var provider: ProfileProvider! = nil
    private var profile: ProfileEditViewModel! = nil

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var menuMyBands: UIButton!
    @IBOutlet weak var menuMyAds: UIButton!
    @IBOutlet weak var menuMusician: UIButton!
    @IBOutlet weak var menuCredentials: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = ProfileProvider()
        self.provider.delegate = self

        do {
            self.view.showSpinner(onView: self.view)
            try self.provider.loadProfile()
        } catch {
            print(error)
        }
        
        menuMyAds.defaultLayout()
        let adIcon = UIImage.fontAwesomeIcon(name: .bullhorn, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
        menuMyAds.setImage(adIcon, for: .normal)
        menuMyAds.titleEdgeInsets = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0)
        
        menuMyBands.defaultLayout()
        let bandIcon = UIImage.fontAwesomeIcon(name: .music, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
        menuMyBands.setImage(bandIcon, for: .normal)
        menuMyBands.titleEdgeInsets = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0)
        
        menuMusician.defaultLayout()
        let musicianIcon = UIImage.fontAwesomeIcon(name: .microphoneAlt, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
        menuMusician.setImage(musicianIcon, for: .normal)
        menuMusician.titleEdgeInsets = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0)
        
        menuCredentials.defaultLayout()
        let creadentialsIcon = UIImage.fontAwesomeIcon(name: .shieldAlt, style: .solid, textColor: .white, size: CGSize(width: 40, height: 40))
        menuCredentials.setImage(creadentialsIcon, for: .normal)
        menuCredentials.titleEdgeInsets = UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0)
        
        
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            goToLogin()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfileSegue" {
            if let profileEditViewController = segue.destination as? ProfileEditViewController {
                profileEditViewController.delegate = self
            }
        }
    }
    
    func editConfig() {
        if let profile = self.profile, let image = profile.getPicturesForView() {
            profileImageView.loading()
            provider.loadImage(image: image, to: profileImageView)
        } else {
            let userIcon = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: UIColor(rgb: 0x222222), size: CGSize(width: 100, height: 100))
            profileImageView.image = userIcon
            profileImageView.contentMode = .center
        }
        nameLabel.text = profile.name
        profileImageView.rounded()
        
    }
    
    func goToLogin() {
        
        if let tabBarController = self.tabBarController, var viewControllers = tabBarController.viewControllers {
            
            let tabBarItem = viewControllers[2].tabBarItem
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.loginNavigationViewController)
            loginViewController.tabBarItem = tabBarItem
            viewControllers[2] = loginViewController
            viewControllers.remove(at: 3)
            tabBarController.viewControllers = viewControllers
            tabBarController.selectedViewController = loginViewController
        
        }
        
    }
}

extension ProfileViewController: ProfileEditViewControllerDelegate {
    func profileDetailViewControllerDidCancel(_ controller: ProfileEditViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func profileDetailViewController(_ controller: ProfileEditViewController, didFinishEditing profile: User) {
        self.profile = ProfileEditViewModel(profile)
        self.editConfig()
        navigationController?.popViewController(animated: true)
    }
}

extension ProfileViewController: ProfileProviderProtocol {
    func providerDidFinishSavingProfile(provider of: ProfileProvider, profile: User) {
        
    }
    func providerDidFinishSavingProfile(provider of: ProfileProvider, error: String) {
        
    }
    func providerDidLoadProfile(provider of: ProfileProvider, profile: ProfileEditViewModel?) {
        if let profile = profile {
            self.profile = profile
            editConfig()
        } else if let error = provider.error {
            print(error.localizedDescription)
        }
        self.view.removeSpinner()
    }
    func providerDidLoadImage(provider of: ProfileProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            profileImageView.image = UIImage(data: data)
            profileImageView.loaded()
        }
    }
}
