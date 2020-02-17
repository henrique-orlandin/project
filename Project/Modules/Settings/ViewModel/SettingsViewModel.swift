//
//  SettingsViewModel.swift
//  Jam
//
//  Created by Henri on 2020-02-12.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//

import Foundation

class SettingsViewModel {
    
     private var notificationBandsMusicians: Bool
     private var notificationMessages: Bool
     private var privacyContactInfo: Bool
    
    init(settings: Settings) {
        self.notificationBandsMusicians = settings.notificationBandsMusicians
        self.notificationMessages = settings.notificationMessages
        self.privacyContactInfo = settings.privacyContactInfo
    }
    
    func getNotificationBandsMusicians() -> Bool {
        return self.notificationBandsMusicians
    }
    
    func getNotificationMessages() -> Bool {
        return self.notificationMessages
    }
    
    func getPrivacyContactInfo() -> Bool {
        return self.privacyContactInfo
    }
    
    func setNotificationBandsMusicians(status: Bool) {
        self.notificationBandsMusicians = status
    }
    
    func setNotificationMessages(status: Bool) {
        self.notificationMessages = status
    }
    
    func setPrivacyContactInfo(status: Bool) {
        self.privacyContactInfo = status
    }
}
