//
//  SignUpViewModel.swift
//  Jam
//
//  Created by Henri on 2019-12-07.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class SignUpViewModel {
    
    var id: String?
    var name: String?
    var email: String?
    var password: String?
    
    init() { }
    
    init(_ user: User) {
        self.id = user.id
        self.name = user.name
    }
    
    func setNameFromView(_ name: String?) {
        self.name = name
    }
    
    func setEmailFromView(_ email: String?) {
        self.email = email
    }
    
    func setPasswordFromView(_ password: String?) {
        self.password = password
    }
    
}
