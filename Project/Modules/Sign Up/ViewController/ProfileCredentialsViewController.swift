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

class ProfileCredentialsViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmErrorLabel: UILabel!
    
    
    var provider: ProfileCredentialsProvider!
    var user: ProfileCredentialsViewModel!
    let validator = Validator()
    
    @IBAction func done(_ sender: Any) {
        
        var hasError = false
        if emailTextField.text != "" {
            validator.validateField(emailTextField) { error in
                if let error = error {
                    error.errorLabel?.text = error.errorMessage
                    error.errorLabel?.alpha = 1
                    hasError = true
                }
            }
        }
        
        if passwordTextField.text != "" {
            validator.validateField(passwordTextField) { error in
                if let error = error {
                    error.errorLabel?.text = error.errorMessage
                    error.errorLabel?.alpha = 1
                    hasError = true
                }
            }
            validator.validateField(confirmTextField) { error in
                if let error = error {
                    error.errorLabel?.text = error.errorMessage
                    error.errorLabel?.alpha = 1
                    hasError = true
                }
            }
        }
        
        if !hasError {
            user.setEmailFromView(emailTextField.text != "" ? emailTextField.text : nil)
            user.setPasswordFromView(passwordTextField.text != "" ? passwordTextField.text : nil)
            provider.saveCredentials(user);
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        provider = ProfileCredentialsProvider()
        provider.delegate = self
        
        user = ProfileCredentialsViewModel()
        
        setUpView()
    }
    
    func setUpView() {
        
        hideError()
        validator.registerField(emailTextField, errorLabel: emailErrorLabel, rules: [EmailRule(message: "Invalid email")])
        validator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [PasswordRule()])
        validator.registerField(confirmTextField, errorLabel: confirmErrorLabel, rules: [ConfirmationRule(confirmField: passwordTextField)])
        
    }
    
    func hideError() {
        emailErrorLabel.alpha = 0;
        passwordErrorLabel.alpha = 0;
        confirmErrorLabel.alpha = 0;
    }
    
}

extension ProfileCredentialsViewController: ProfileCredentialsProviderProtocol {
    func providerDidSave(provider of: ProfileCredentialsProvider, error: String?) {
        guard error == nil else {
            let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            return
        }
        
        navigationController?.popViewController(animated: true)
        
    }
}

extension  ProfileCredentialsViewController: ValidationDelegate {
    func validationSuccessful() {
        user.setEmailFromView(emailTextField.text)
        user.setPasswordFromView(passwordTextField.text)
        
        provider.saveCredentials(user);
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        hideError()
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.alpha = 1
        }
    }
}
