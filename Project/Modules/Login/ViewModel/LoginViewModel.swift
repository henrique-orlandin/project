//
//  LoginViewModel.swift
//  Jam
//
//  Created by Henri on 2019-12-04.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class LoginViewModel {
    
    var id: Int?
    var email: String?
    var password: String?
    
    init() { }
    
    init(_ user: User) {
        self.id = user.id
        self.email = user.email
    }
    
    func setEmailFromView(_ email: String?) {
        self.email = email
    }
    
    func setPasswordFromView(_ password: String?) {
        self.password = password
    }
    
}
