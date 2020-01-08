//
//  SignUpViewController.swift
//  Jam
//
//  Created by Henri on 2019-11-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftValidator

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    var provider: SignUpProvider!
    var user: SignUpViewModel!
    let validator = Validator()
    
    @IBAction func signUp(_ sender: Any) {
        validator.validate(self)
    }
    
    @IBAction func backToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provider = SignUpProvider()
        provider.delegate = self
        
        user = SignUpViewModel()
        
        setUpView()
    }
    
    func setUpView() {
        
        hideError()
        validator.registerField(nameTextField, errorLabel: nameErrorLabel, rules: [RequiredRule()])
        validator.registerField(emailTextField, errorLabel: emailErrorLabel, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
        validator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule(), PasswordRule()])
        
    }
    
    func hideError() {
        nameErrorLabel.alpha = 0;
        emailErrorLabel.alpha = 0;
        passwordErrorLabel.alpha = 0;
    }
    
    func goToProfile() {
        
        if let tabBarController = self.tabBarController {
            
            var viewControllers = tabBarController.viewControllers
            let tabBarItem = viewControllers?[1].tabBarItem
            viewControllers?.remove(at: 1)
            tabBarController.viewControllers = viewControllers
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let profileViewController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.profileNavigationViewController)
            profileViewController.tabBarItem = tabBarItem
            tabBarController.viewControllers?.append(profileViewController)
            tabBarController.selectedViewController = profileViewController
        }
        
    }
}

extension SignUpViewController: SignUpProviderProtocol {
    func providerDidCreate(provider of: SignUpProvider, error: String?) {
        guard error == nil else {
            let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        goToProfile()
    }
}

extension SignUpViewController: ValidationDelegate {
    func validationSuccessful() {
        user.setNameFromView(nameTextField.text)
        user.setEmailFromView(emailTextField.text)
        user.setPasswordFromView(passwordTextField.text)
        
        provider.create(user);
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        hideError()
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.alpha = 1
        }
    }
}
