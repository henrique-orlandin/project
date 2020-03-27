//
//  BandListProvider.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import FirebaseFirestore
import FirebaseAuth

class SettingsProvider {
    
    weak var delegate : SettingsProviderProtocol?
    private var settings: NSFetchedResultsController<Settings>!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getSettings() -> Settings {
        let settingsData = settings.object(at: IndexPath(row: 0, section: 0))
        return settingsData
    }
    
    func loadSettings() {
        let context = appDelegate.persistentContainer.viewContext
        let request = Settings.fetchRequest() as NSFetchRequest<Settings>
        let sort = NSSortDescriptor(key: #keyPath(Settings.notificationBandsMusicians), ascending: true)
        request.sortDescriptors = [sort]
        do {
            settings = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try settings.performFetch()
            if let objects = settings.fetchedObjects, objects.count > 0 {
                delegate?.providerDidLoadSettings(provider: self)
                return
            }
            
            if Auth.auth().currentUser != nil {
                let db = Firestore.firestore()
                db.collection("settings").document(Auth.auth().currentUser!.uid).getDocument(completion: {
                    snapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                        self.delegate?.providerDidLoadSettings(provider: self)
                    } else {
                        if let data = snapshot?.data() {
                            let _ = self.addSettings(data: data)
                            self.loadSettings()
                        }
                    }
                })
            } else {
                let _ = addSettings(data: [String:Any]())
                settings = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                try settings.performFetch()
                delegate?.providerDidLoadSettings(provider: self)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateSettings(settings data: SettingsViewModel) {
        let settingsData = settings.object(at: IndexPath(row: 0, section: 0))
        settingsData.notificationBandsMusicians = data.getNotificationBandsMusicians()
        settingsData.notificationMessages = data.getNotificationMessages()
        settingsData.privacyContactInfo = data.getPrivacyContactInfo()
        appDelegate.saveContext()
        
        if Auth.auth().currentUser != nil {
            let db = Firestore.firestore()
            let settings: [String: Any] = [
                "notificationBandsMusicians": data.getNotificationBandsMusicians(),
                "notificationMessages": data.getNotificationMessages(),
                "privacyContactInfo": data.getPrivacyContactInfo(),
            ]
            db.collection("settings").document(Auth.auth().currentUser!.uid).updateData(settings)
        }
    }
    
    func addSettings(data: [String:Any]) -> Settings {
        let context = appDelegate.persistentContainer.viewContext
        let settingsData = Settings(entity: Settings.entity(), insertInto: context)
        settingsData.notificationBandsMusicians = data["notificationBandsMusicians"] as? Bool ?? true
        settingsData.notificationMessages = data["notificationMessages"] as? Bool ?? true
        settingsData.privacyContactInfo = data["privacyContactInfo"] as? Bool ?? true
        appDelegate.saveContext()
        
        return settingsData
    }
}

protocol SettingsProviderProtocol:class{
    func providerDidLoadSettings(provider of: SettingsProvider)
}
