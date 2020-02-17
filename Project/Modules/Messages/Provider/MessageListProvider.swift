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

class MessageListProvider {
    
    weak var delegate : MessageListProviderProtocol?
    private var messages: [Message]?
    private var error: Error?
    private var chat: Chat?
    
    var numberOfMessages: Int {
        if let list = messages {
            return list.count
        } else {
            return 0
        }
    }
    
    enum ProviderError: Error {
        case invalidURL
        case unreacheble
        case badFormat
    }
    
    public func getChat() -> Chat? {
        return self.chat
    }
    
    public func getMessageViewModel(row withRID: Int, section withSID: Int) -> MessageListViewModel? { 
        guard let list = messages else {
            return nil
        }
        return MessageListViewModel(list[withRID])
    }
    
    public func getMessageIndex(indexOf message: Message) -> Int? {
        guard let list = self.messages else {
            return nil
        }
        return list.firstIndex(of: message)
    }
    
    public func getMessage(indexOf index: Int) -> Message? {
        guard let list = messages else {
            return nil
        }
        return list[index]
    }
    
    public func updateMessage(_ message: Message, at index: Int) {
        messages?[index] = message
    }
    
    public func addMessage(_ message: Message) {
        messages?.append(message)
    }
    
    public func loadMessages(chat: String) {
        
        var messageList = [Message]()
        
        let db = Firestore.firestore()
        
        let ref = db.collection("chats/\(chat)/messages")
        ref.order(by: "sent", descending: false).getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let message = self.decode(id: document.documentID, data: data) {
                        messageList.append(message)
                    }
                }
                self.messages = messageList
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
            }
        })
        
    }
    
    func saveBand(chat: String, message: String) {
        
        let data:[String: Any] = [
            "content": message,
            "sender": Auth.auth().currentUser!.uid,
            "sent": Timestamp(),
            "read": false
        ]

        let db = Firestore.firestore()
        
        db.collection("chats/\(chat)/messages").document().setData(data, completion: {
            (error) in
            if let error = error {
                print(error)
            }
        })
        
    }
    
    public func startListeningForChanges(chat: String) {
        let db = Firestore.firestore()
        
        let ref = db.collection("chats/\(chat)/messages")
        ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                switch change.type {
                case .added:
                    let data = change.document.data()
                    if let messages = self.messages, let message = self.decode(id: change.document.documentID, data: data) {
                        if !messages.contains(message) {
                            self.messages?.append(message)
                            self.delegate?.providerDidFinishAddingMessage(provider: self)
                        }
                        if message.sender != Auth.auth().currentUser!.uid {
                            self.setMessageViewed(chat: chat)
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    func setMessageViewed(chat: String) {
        
        let db = Firestore.firestore()
        
        db.collection("chats/\(chat)/messages")
            .whereField("read", isEqualTo: false)
            .getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let sender = data["sender"] as? String, sender != Auth.auth().currentUser!.uid {
                        db.collection("chats/\(chat)/messages")
                            .document(document.documentID)
                            .updateData(["read": true])
                    }
                }
            }
        })
        
    }
    
    
    func decode(id: String, data:[String: Any]) -> Message? {
        
        guard let sender = data["sender"] as? String,
            let content = data["content"] as? String else {
                return nil
        }
        
        var sent: Date?
        if let sentData = data["sent"] as? Timestamp {
            sent = sentData.dateValue()
        }
        let message = Message(id: id, sender: sender, content: content, sent: sent)
        
        return message
    }
    
    
    public func loadChat(chat: String) {
        
        let db = Firestore.firestore()
        db.collection("chats").document(chat).getDocument(completion: {
            document, error in
            if let error = error {
                self.error = error
            } else {
                if let document = document, let data = document.data() {
                    if var chat = self.decodeChat(id: document.documentID, data: data) {
                        
                        db.collection("users").document(chat.id_user).getDocument(completion: {
                            document, error in
                            if let error = error {
                                self.error = error
                            } else  if let document = document, let data = document.data() {
                                let user = self.decodeUser(id: document.documentID, data: data)
                                chat.user = user
                                
                                if let id_band = chat.id_band {
                                    db.collection("bands").document(id_band).getDocument(completion: {
                                       document, error in
                                       if let error = error {
                                           self.error = error
                                       } else  if let document = document, let data = document.data() {
                                            let band = self.decodeBand(id: document.documentID, data: data)
                                            if let user = data["id_user"] as? String, user == chat.id_user {
                                                chat.band = band
                                            }
                                            self.chat = chat
                                            self.delegate?.providerDidFinishLoadingChat(provider: self)
                                        }
                                    })
                                } else {
                                    self.chat = chat
                                    self.delegate?.providerDidFinishLoadingChat(provider: self)
                                }
                            }
                        })
                    }
                }
                
            }
        })
    }
    
    
    func decodeChat(id: String, data:[String: Any]) -> Chat? {
        
        guard let users = data["id_user"] as? [String] else {
            return nil
        }
        
        let id_band = data["id_band"] as? String ?? nil
        var id_user: String? = nil
        for user in users {
            if user != Auth.auth().currentUser?.uid {
                id_user = user
            }
        }
            
        var lastMessage: Message?
        if let last = data["lastMessage"] as? [String: Any],
            let sender = last["sender"] as? String,
            let content = last["content"] as? String,
            let sent = last["sent"] as? Timestamp {
            lastMessage = Message(id: "", sender: sender, content: content, sent: sent.dateValue())
        }
        
        let chat = Chat(id: id, id_user: id_user!, id_band: id_band, band: nil, user: nil, lastMessage: lastMessage)
        
        return chat
    }
    
    func decodeUser(id: String, data:[String: Any]) -> User? {
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        let user = User(id: id, name: name, image: nil, location: nil, musician: nil)
        
        return user
    }
    
    func decodeBand(id: String, data:[String: Any]) -> Band? {
        
        guard
            let name = data["name"] as? String,
            let image = data["image"] as? String,
            let description = data["description"] as? String,
            let genres = data["genre"] as? [String],
            let location = data["location"] as? [String: Any]
            else {
                return nil
        }
        
        guard let lat_lng = location["lat_lng"] as? GeoPoint else {
            return nil
        }
        
        let loc = Location(city: location["city"] as? String, state: location["state"] as? String, country: location["country"] as? String, postalCode: location["postal_code"] as? String, lat: lat_lng.latitude, lng: lat_lng.longitude)
        
        var genreList = [Genre]()
        for genre in genres {
            if let value = Genre(rawValue: genre) {
                genreList.append(value)
            }
        }
        
        let band = Band(id: id, name: name, image: image, description: description, genres: genreList, location: loc, gallery: nil, reviews: nil, contact: nil, videos: nil, audios: nil, links: nil, musicians: nil)
        
        return band
    }
    
}

protocol MessageListProviderProtocol:class{
    func providerDidFinishUpdatedDataset(provider of: MessageListProvider)
    func providerDidFinishAddingMessage(provider of: MessageListProvider)
    func providerDidFinishLoadingChat(provider of: MessageListProvider)
}
