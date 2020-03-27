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
import FirebaseStorage

@objc class ChatListProvider: NSObject {
    
    weak var delegate : ChatListProviderProtocol?
    private var chats: [Chat]?
    private var error: Error?
    private var loadingSubcontent: Int? = nil {
        didSet {
            if self.loadingSubcontent == 0 {
                self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
                self.loadingSubcontent = nil
            }
        }
    }
    
    var numberOfChats: Int {
        if let list = chats {
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
    
    public func getChatViewModel(row withRID: Int, section withSID: Int) -> ChatListViewModel? {
        guard let list = chats else { 
            return nil
        }
        return ChatListViewModel(list[withRID])
    }
    
    public func getChatIndex(indexOf chat: Chat) -> Int? {
        guard let list = self.chats else {
            return nil
        }
        return list.firstIndex(of: chat)
    }
    
    func loadImage(image: String, to imageView: UIImageView, ofType type: String) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("\(type)/\(image)")
        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else if let data = data, let image = UIImage(data: data) {
                self.delegate?.providerDidLoadImage?(provider: self, image: image, imageView: imageView)
            }
        }
    }
    
    public func getChat(indexOf index: Int) -> Chat? {
        guard let list = chats else {
            return nil
        }
        return list[index]
    }
    
    public func updateChat(_ chat: Chat, at index: Int) {
        chats?[index] = chat
    }
    
    public func addChat(_ chat: Chat) {
        chats?.append(chat)
    }
    
    public func loadChats() {
        
        var chatList = [Chat]()
        
        let db = Firestore.firestore()
        db.collection("chats").whereField("id_user", arrayContains: Auth.auth().currentUser!.uid).order(by: "lastMessage.sent", descending: true).getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
            } else {
                self.loadingSubcontent = querySnapshot!.documents.count
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let chat = self.decode(id: document.documentID, data: data) {
                        chatList.append(chat)
                    }
                }
                self.chats = chatList
                self.loadSubcontentData()
            }
        })
    }
    
    public func loadSubcontentData() {
        
        let db = Firestore.firestore()
        if let chats = chats {
            for (index, chat) in chats.enumerated() {
                
                var updatedChat: Chat = chat
                
                
                db.collection("users").document(chat.id_user).getDocument(completion: {
                    document, error in
                    if let error = error {
                        self.error = error
                    } else  if let document = document, let data = document.data() {
                        let user = self.decodeUser(id: document.documentID, data: data)
                        updatedChat.user = user
                        
                        if let id_band = chat.id_band {
                            db.collection("bands").document(id_band).getDocument(completion: {
                               document, error in
                               if let error = error {
                                   self.error = error
                               } else  if let document = document, let data = document.data() {
                                    let band = self.decodeBand(id: document.documentID, data: data)
                                    if let user = data["id_user"] as? String, user == chat.id_user {
                                        updatedChat.band = band
                                    }
                                    self.chats?[index] = updatedChat
                                    self.loadingSubcontent = self.loadingSubcontent! - 1
                                }
                            })
                        } else {
                            self.chats?[index] = updatedChat
                            self.loadingSubcontent = self.loadingSubcontent! - 1
                        }
                    }
                })
                
            }
        }
        
    }
    
    func decode(id: String, data:[String: Any]) -> Chat? {
        
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
        
        var image: String?
        if let userImage = data["image"] as? String {
            image = userImage
        }
        
        let user = User(id: id, name: name, image: image, location: nil, musician: nil)
        
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

@objc protocol ChatListProviderProtocol:class{
    @objc optional func providerDidFinishUpdatedDataset(provider of: ChatListProvider)
    @objc optional func providerDidLoadImage(provider of: ChatListProvider, image: UIImage, imageView: UIImageView)
}
