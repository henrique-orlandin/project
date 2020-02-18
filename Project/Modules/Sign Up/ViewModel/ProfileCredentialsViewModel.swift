//
//  SignUpViewModel.swift
//  Jam
//
//  Created by Henri on 2019-12-07.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class ProfileCredentialsViewModel {
    
    var id: String?
    var email: String?
    var password: String?
    
    init() { }
    
    init(_ user: User) {
        self.id = user.id
    }
    
    func setEmailFromView(_ email: String?) {
        self.email = email
    }
    
    func setPasswordFromView(_ password: String?) {
        self.password = password
    }
    
    func getEmailForView(_ email: String?) {
        self.email = email
    }
    
}
