//
//  SettingsViewController.swift
//  Jam
//
//  Created by Henri on 2020-02-10.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var provider: SettingsProvider! = nil
    var settings: SettingsViewModel! = nil
    
    @IBOutlet weak var noficaitionBandsMusiciansSwitch: UISwitch!
    @IBOutlet weak var noficaitionMessagesSwitch: UISwitch!
    @IBOutlet weak var privacyContactInfoSwitch: UISwitch!
    
    @IBAction func notificationBandsMusiciansChange(_ sender: UISwitch) {
        settings.setNotificationBandsMusicians(status: sender.isOn)
        provider.updateSettings(settings: settings)
    }
    
    @IBAction func notificationMessagesChange(_ sender: UISwitch) {
        settings.setNotificationMessages(status: sender.isOn)
        provider.updateSettings(settings: settings)
    }
    
    @IBAction func privacyContactInfoChange(_ sender: UISwitch) {
        settings.setPrivacyContactInfo(status: sender.isOn)
        provider.updateSettings(settings: settings)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider = SettingsProvider()
        provider.delegate = self
        provider.loadSettings()
    }
    
    func configView() {
        if settings != nil {
            noficaitionBandsMusiciansSwitch.isOn = settings.getNotificationBandsMusicians()
            noficaitionMessagesSwitch.isOn = settings.getNotificationMessages()
            privacyContactInfoSwitch.isOn = settings.getPrivacyContactInfo()
        }
    }
    
}

extension SettingsViewController: SettingsProviderProtocol {
    func providerDidLoadSettings(provider of: SettingsProvider) {
        let settingsData = provider.getSettings()
        settings = SettingsViewModel(settings: settingsData)
        configView()
    }
    
    func providerDidUpdatedSettings(provider of: SettingsProvider) {
        
    }
    
}
