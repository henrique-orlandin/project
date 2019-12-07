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

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    @IBAction func signUp(_ sender: Any) {
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text
        else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (result, error) in
            if error != nil {
                self.showError("Unable to create user login")
            }
            else {
                let db = Firestore.firestore()
                let data = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "uid": result!.user.uid
                ]
                db.collection("users").addDocument(data: data, completion: {
                    (error) in
                    if error != nil {
                        self.showError("Unable to create user!")
                    }
                    else {
                        let profileViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileNavigationViewController) as? ProfileViewController
                        
                        self.view.window?.rootViewController = profileViewController
                        self.view.window?.makeKeyAndVisible()
                    }
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView() {
        errorLabel.alpha = 0
    }
    
    func showError(_ message: String) {
        errorLabel.text = message;
        errorLabel.alpha = 1
    }
}
