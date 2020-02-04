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

class SignUpProvider {
    
    weak var delegate: SignUpProviderProtocol?
    
    public var isLogged: Bool {
        return Auth.auth().currentUser != nil
    }
    
    public func create (_ user: SignUpViewModel) {
        
        guard let name = user.name,
              let email = user.email,
              let password = user.password else { return }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            (result, error) in
            if let error = error {
                self.delegate?.providerDidCreate(provider: self, error: error.localizedDescription)
            }
            else {
                
                let db = Firestore.firestore()
                var data = [
                    "id": result!.user.uid,
                    "name": name,
                    "email": email
                ]
                
                if let fcmToken = Messaging.messaging().fcmToken {
                    data["token"] = fcmToken
                }
                
                db.collection("users").document(result!.user.uid).setData(data, completion: {
                    (error) in
                    if let error = error {
                        self.delegate?.providerDidCreate(provider: self, error: error.localizedDescription)
                    }
                    else {
                        self.delegate?.providerDidCreate(provider: self, error: nil)
                    }
                })
            }
        })
    }
}

protocol SignUpProviderProtocol:class {
    func providerDidCreate(provider of: SignUpProvider, error: String?);
}
