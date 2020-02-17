//
//  LoginViewController.swift
//  Jam
//
//  Created by Henri on 2019-11-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import SwiftValidator
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    var provider: LoginProvider!
    var user: LoginViewModel!
    let validator = Validator()
    
    @IBAction func doLogin(_ sender: Any) {
        validator.validate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provider = LoginProvider()
        provider.delegate = self
        
        user = LoginViewModel()
        
        if provider.isLogged {
            goToProfile()
        }
        setUpView()
    }
    
    func setUpView() {
        
        hideError()
        
        validator.registerField(emailTextField, errorLabel: emailErrorLabel, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        validator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule()])
    }
    
    func goToProfile(adChat: Bool = false) {
        
        if let tabBarController = self.tabBarController, var viewControllers = tabBarController.viewControllers {
            
            let tabBarItem = viewControllers[2].tabBarItem
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.profileNavigationViewController)
            profileViewController.tabBarItem = tabBarItem
            
            viewControllers[2] = profileViewController
            
            if adChat {
                let messagesStoryboard = UIStoryboard(name: "Messages", bundle: nil)
                let messagesViewController = messagesStoryboard.instantiateViewController(withIdentifier: Constants.Storyboard.chatNavigationViewController)
                
                let item = UITabBarItem()
                item.title = "Chat"
                item.image = UIImage(systemName: "message")
                
                messagesViewController.tabBarItem = item
                let settings = viewControllers[3]
                viewControllers[3] = messagesViewController
                
                viewControllers.append(settings)
            }
            
            tabBarController.viewControllers = viewControllers
            tabBarController.selectedViewController = profileViewController
            
        }
        
    }
    
    func hideError() {
        emailErrorLabel.alpha = 0;
        passwordErrorLabel.alpha = 0;
    }
    
}

extension LoginViewController: LoginProviderProtocol {
    func providerDidLogin(provider of: LoginProvider, error: String?) {
        guard error == nil else {
            let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        goToProfile(adChat: true)
    }
}


extension LoginViewController: ValidationDelegate {
    func validationSuccessful() {
        user.setEmailFromView(emailTextField.text)
        user.setPasswordFromView(passwordTextField.text)
        
        provider.login(user);
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        hideError()
        for (_ , error) in errors {
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.alpha = 1
        }
    }
}
