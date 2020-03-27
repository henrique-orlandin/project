//
//  AppDelegate.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseAuth
import FirebaseFirestore
import GoogleMaps
import CoreData

let googleApiKey = "AIzaSyCI6b0NuKk9RNplRLRquPd0BC4CwT-jFWM"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var settings: NSFetchedResultsController<Settings>!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleApiKey)
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    
        UINavigationBar.appearance().barTintColor = UIColor(rgb: 0x222222)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Raleway-Medium", size: 22)!
        ]
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Jam")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let payload = notification.request.content
        guard let type = payload.userInfo["type"] as? String else { return }
        
        
        if UIApplication.shared.applicationState == .active && type == "message" {
            completionHandler([])
        } else {
            completionHandler([.alert])
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        defer { completionHandler() }
        
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else { return }
        let payload = response.notification.request.content
        guard let type = payload.userInfo["type"] as? String, let id = payload.userInfo["id"] as? String
          else { return }
        
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            
            if type == "band" {
                let storyboard = UIStoryboard(name: "Bands", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "bandDetailVC") as! BandDetailViewController
                vc.id = id
                
                if let tab = sd.window?.rootViewController as? UITabBarController,
                   let nav = tab.selectedViewController as? UINavigationController {
                    
                    nav.pushViewController(vc, animated: true)
                }
                
            } else if type == "musician" {
                let storyboard = UIStoryboard(name: "Musicians", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "musicianDetailVC") as! MusiciansDetailViewController
                vc.id = id
                if let tab = sd.window?.rootViewController as? UITabBarController,
                   let nav = tab.selectedViewController as? UINavigationController {
                    
                    nav.pushViewController(vc, animated: true)
                }
            } else if type == "message" {
               let storyboard = UIStoryboard(name: "Messages", bundle: nil)
               let vc = storyboard.instantiateViewController(withIdentifier: "messageListVC") as! MessageListViewController
               vc.chat_id = id
               if let tab = sd.window?.rootViewController as? UITabBarController,
                  let nav = tab.selectedViewController as? UINavigationController {
                   nav.pushViewController(vc, animated: true)
               }
           }
        }
        
    }
    
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).updateData(["token": fcmToken])
        }
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

    }
}
