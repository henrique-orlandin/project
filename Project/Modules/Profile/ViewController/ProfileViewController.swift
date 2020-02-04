//
//  ProfileViewController.swift
//  Jam
//
//  Created by Henri on 2019-12-01.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    private var provider: ProfileProvider! = nil
    private var profile: ProfileEditViewModel! = nil

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = ProfileProvider()
        self.provider.delegate = self

        do {
            try self.provider.loadProfile()
        } catch {
            print(error)
        }
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
            provider.loadImage(image: image, to: profileImageView)
        }
        nameLabel.text = profile.name
    }
    
    func goToLogin() {
        
        if let tabBarController = self.tabBarController {
            
            var viewControllers = tabBarController.viewControllers
            let tabBarItem = viewControllers?[1].tabBarItem
            viewControllers?.remove(at: 1)
            tabBarController.viewControllers = viewControllers
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.loginNavigationViewController)
            loginViewController.tabBarItem = tabBarItem
            tabBarController.viewControllers?.append(loginViewController)
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
    }
    func providerDidLoadImage(provider of: ProfileProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            profileImageView.image = UIImage(data: data)
        }
    }
}
