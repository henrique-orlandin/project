//
//  SignUpProvider.swift
//  Jam
//
//  Created by Henri on 2019-12-07.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class ProfileCredentialsProvider {
    
    weak var delegate: ProfileCredentialsProviderProtocol?
    
    public func saveCredentials (_ user: ProfileCredentialsViewModel) {
        
        if let email = user.email {
            Auth.auth().currentUser?.updateEmail(to: email) { (error) in
                if let error = error {
                    self.delegate?.providerDidSave(provider: self, error: error.localizedDescription)
                } else {
                    self.delegate?.providerDidSave(provider: self, error: nil)
                }
            }
        }
        
        if let password = user.password {
            Auth.auth().currentUser?.updatePassword(to: password) { (error) in
                if user.email == nil {
                    self.delegate?.providerDidSave(provider: self, error: nil)
                }
            }
        }
    }
}

protocol ProfileCredentialsProviderProtocol:class {
    func providerDidSave(provider of: ProfileCredentialsProvider, error: String?);
}
