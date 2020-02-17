//
//  BandListProvider.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class TabBarProvider {
    
    weak var delegate : TabBarProviderProtocol?
    private var error: Error?
    
    var unreadMessages: Int = 0
   
    
    public func startListeningForChanges() {
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        
        let ref = db.collection("chats").whereField("id_user", arrayContains: currentUser.uid)
        ref.addSnapshotListener { querySnapshot, error in
            guard let _ = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            self.checkUnreadMessages()
        }
    }
    
    public func checkUnreadMessages() {
        
        let db = Firestore.firestore()
        db.collection("chats")
            .whereField("id_user", arrayContains: Auth.auth().currentUser!.uid)
            .whereField("lastMessage.read", isEqualTo: false)
            .getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
            } else {
                var count = 0
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let lastMessage = data["lastMessage"] as? [String: Any], let sender = lastMessage["sender"] as? String {
                        if sender != Auth.auth().currentUser!.uid {
                            count += 1
                        }
                    }
                }
                self.unreadMessages = count
                self.delegate?.providerDidCheckForNewMessages(provider: self)
            }
        })
    }
    
}

protocol TabBarProviderProtocol:class{
    func providerDidCheckForNewMessages(provider of: TabBarProvider)
}
