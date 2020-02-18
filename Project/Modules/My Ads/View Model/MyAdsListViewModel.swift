//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class MyAdsListViewModel {
    
    var id: String?
    var type: Advertising.AdType?
    var user: User?
    var band: Band?
    
    init() { }
    
    init(_ ad: Advertising) {
        self.id = ad.id
        self.type = ad.type
        self.user = ad.user
        self.band = ad.band
    }
    
    func getTypeForView() -> Advertising.AdType? {
        return self.type
    }
    func getBandForView() -> Band? {
        return self.band
    }
    func getUserForView() -> User? {
        return self.user
    }
}
