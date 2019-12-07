//
//  LoginProvider.swift
//  Jam
//
//  Created by Henri on 2019-12-04.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import FirebaseAuth

class LoginProvider {
    
    weak var delegate: LoginProviderProtocol?
    
    public var isLogged: Bool {
        return Auth.auth().currentUser != nil
    }
    
    public func login (_ user: LoginViewModel) {
        
        guard let email = user.email, let password = user.password else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            (result, error) in
            if error != nil {
                self.delegate?.providerDidLogin(provider: self, error: "Invalid email or password!")
            } else {
                self.delegate?.providerDidLogin(provider: self, error: nil)
            }
        })
    }
}

protocol LoginProviderProtocol:class {
    func providerDidLogin(provider of: LoginProvider, error: String?);
}
