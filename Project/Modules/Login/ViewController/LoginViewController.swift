//
//  LoginViewController.swift
//  Jam
//
//  Created by Henri on 2019-11-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var provider: LoginProvider!
    var user: LoginViewModel!
    
    @IBAction func doLogin(_ sender: Any) {
        if let error = user.validate() {
            showError(error)
            return
        }
        provider.login(user);
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
        errorLabel.alpha = 0
        
        emailTextField.addTarget(self, action: #selector(emailDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
    }
    
    func showError(_ message: String) {
        errorLabel.text = message;
        errorLabel.alpha = 1
    }
    
    func goToProfile() {
        
        if let tabBarController = self.tabBarController {
            
            var viewControllers = tabBarController.viewControllers
            let tabBarItem = viewControllers?[1].tabBarItem
            viewControllers?.remove(at: 1)
            tabBarController.viewControllers = viewControllers
            
            if let profileViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.profileNavigationViewController) {
                profileViewController.tabBarItem = tabBarItem
                tabBarController.viewControllers?.append(profileViewController)
                tabBarController.selectedViewController = profileViewController
            }
        }
        
    }
    
    @objc func emailDidChange() {
        self.user.setEmailFromView(emailTextField.text)
    }
    @objc func passwordDidChange() {
        self.user.setPasswordFromView(passwordTextField.text)
    }
    
}

extension LoginViewController: LoginProviderProtocol {
    func providerDidLogin(provider of: LoginProvider, error: String?) {
        guard error == nil else {
            self.showError(error!)
            return
        }
        goToProfile()
    }
}
