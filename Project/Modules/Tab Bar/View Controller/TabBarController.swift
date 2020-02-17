//
//  TabBarController.swift
//  Jam
//
//  Created by Henri on 2020-02-10.
//  Copyright © 2020 Henrique Orlandin. All rights reserved.
//

import UIKit
import FirebaseAuth
class TabBarController: UITabBarController {

    var provider: TabBarProvider! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = TabBarProvider()
        self.provider.delegate = self
        self.provider.startListeningForChanges()
        
        if var viewControllers = self.viewControllers, Auth.auth().currentUser == nil {
            
            viewControllers.remove(at: 3)
            self.viewControllers = viewControllers
            
        }
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
