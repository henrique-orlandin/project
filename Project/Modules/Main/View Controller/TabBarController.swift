//
//  TabBarController.swift
//  Jam
//
//  Created by Henri on 2020-02-10.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FontAwesome_swift
class TabBarController: UITabBarController {
    
    var provider: TabBarProvider! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = TabBarProvider()
        self.provider.delegate = self
        self.provider.startListeningForChanges()
        
        if var viewControllers = self.viewControllers {
            
            if Auth.auth().currentUser == nil {
                viewControllers.remove(at: 3)
                self.viewControllers = viewControllers
            }
            
            for viewController in viewControllers {
                let attributes = [NSAttributedString.Key.font:UIFont(name: "Raleway", size: 11)]
                let item = viewController.tabBarItem!
                item.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for:.normal)
                
                
                var font: FontAwesome! = nil
                if item.title == "Bands" {
                    font = .music
                } else if item.title == "Musicians" {
                    font = .microphoneAlt
                } else if item.title == "Profile" {
                    font = .userCircle
                } else if item.title == "Chat" {
                    font = .comments
                } else if item.title == "Settings" {
                    font = .cogs
                }
                
                let icon = UIImage.fontAwesomeIcon(name: font, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
                item.image = icon
                item.selectedImage = icon
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = UIColor(rgb: 0x222222)
            view.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
            
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor(rgb: 0x222222)
        }
        
        
        self.tabBar.barTintColor = UIColor(rgb: 0x222222);
        self.tabBar.tintColor = UIColor.white
    }
}

extension TabBarController: TabBarProviderProtocol {
    func providerDidCheckForNewMessages(provider of: TabBarProvider) {
        
        
        if let tabItems = self.tabBar.items {
            let tabItem = tabItems[3]
            if provider.unreadMessages > 0 {
                tabItem.badgeValue = String(provider.unreadMessages)
            } else {
                tabItem.badgeValue = nil
            }
        }
    }
}
