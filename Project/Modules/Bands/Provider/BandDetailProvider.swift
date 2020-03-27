//
//  BandDetailProvider.swift
//  Jam
//
//  Created by Henri on 2019-12-19.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class BandDetailProvider {
    
    weak var delegate : BandDetailProviderProtocol?
    
    private var band: BandDetailViewModel?
    public var error: Error?
    
    enum ProviderError: Error {
        case decodeError
    }
    
    public func getBand() -> BandDetailViewModel? {
        guard let item = band else {
            return nil
        }
        return item
    }
    
    func loadImage(image: String, to imageView: UIImageView) {
        
        guard let band = band else {
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("bands/\(band.image)")
        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                self.delegate?.providerDidLoadImage(provider: self, imageView: imageView, data: nil)
            } else {
                self.delegate?.providerDidLoadImage(provider: self, imageView: imageView, data: data)
            }
        }
    }
    
    public func chat() {
        let db = Firestore.firestore()
        let currentUser = Auth.auth().currentUser!.uid
        db.collection("chats").whereField("id_user", arrayContains: currentUser).getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
            } else {
                var chatId: String?
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let bandId = data["id_band"] as? String {
                        if bandId == self.band!.id {
                            chatId = document.documentID
                        }
                    }
                }
                
                if let chatId = chatId {
                    self.delegate?.providerDidFindChat(provider: self, chatId: chatId)
                } else {
                    let newChat = db.collection("chats").document()
                    newChat.setData(["id_band": self.band!.id, "id_user": [self.band!.user!.id, currentUser]]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            self.delegate?.providerDidFindChat(provider: self, chatId: newChat.documentID)
                        }
                    }
                }
            }
            
        })
    }
    
    public func loadBand(_ id: String) throws {
        
        let db = Firestore.firestore()
        db.collection("bands").document(id).getDocument(completion: {
            document, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishLoading(provider: self, band: self.band)
            } else if
                let document = document,
                let data = document.data(),
                let band = self.decode(id: document.documentID, data: data) {
                if let userId = data["id_user"] as? String {
                    db.collection("users").document(userId).getDocument(completion: {
                        userDocument, error in
                        if let error = error {
                            self.error = error
                        } else if
                            let userDocument = userDocument,
                            let userData = userDocument.data(),
                            let user = self.decodeUser(id: userDocument.documentID, data: userData) {
                            self.band = BandDetailViewModel(band, user: user)
                            self.delegate?.providerDidFinishLoading(provider: self, band: self.band)
                        }
                    })
                }
            } else {
                self.error = ProviderError.decodeError
                self.delegate?.providerDidFinishLoading(provider: self, band: self.band)
            }
        })
    }
    
    func decode(id: String, data:[String: Any]) -> Band? {
        
        guard
            let name = data["name"] as? String,
            let image = data["image"] as? String,
            let description = data["description"] as? String,
            let genres = data["genre"] as? [String],
            let location = data["location"] as? [String: Any]
        else {
            return nil
        }
        
        guard
            let city = location["city"] as? String,
            let country = location["country"] as? String,
            let lat_lng = location["lat_lng"] as? GeoPoint
        else {
            return nil
        }
        
        let loc = Location(city: city, state: location["state"] as? String, country: country, lat: lat_lng.latitude, lng: lat_lng.longitude)
        
        var genreList = [Genre]()
        for genre in genres {
            if let value = Genre(rawValue: genre) {
                genreList.append(value)
            }
        }
        
        let band = Band(id: id, name: name, image: image, description: description, genres: genreList, location: loc, gallery: nil, reviews: nil, contact: nil, videos: nil, audios: nil, links: nil, musicians: nil)
            
        return band
    }
    
    func decodeUser(id: String, data:[String: Any]) -> User? {
        
        guard let name = data["name"] as? String else {
              return nil
          }
          
          let isMusician = data["is_musician"] as? Bool
          let image = data["image"] as? String
          let description = data["description"] as? String
          
          var loc:Location? = nil
          if let location = data["location"] as? [String: Any], let lat_lng = location["lat_lng"] as? GeoPoint {
              loc = Location(city: location["city"] as? String, state: location["state"] as? String, country: location["country"] as? String, postalCode: location["postal_code"] as? String, lat: lat_lng.latitude, lng: lat_lng.longitude)
          }
          
          var genreList = [Genre]()
          if let genres = data["genre"] as? [String] {
              for genre in genres {
                  if let value = Genre(rawValue: genre) {
                      genreList.append(value)
                  }
              }
          }
          
          var skillList = [Skills]()
          if let skills = data["skills"] as? [String] {
              for skill in skills {
                  if let value = Skills(rawValue: skill) {
                      skillList.append(value)
                  }
              }
          }
          
          var musician: Musician? = nil
          if isMusician != nil, isMusician == true, let desc = description {
              musician = Musician(description: desc, genres: genreList, skills: skillList, gallery: nil, reviews: nil, contact: nil, videos: nil, audios: nil, links: nil)
          }
          let user = User(id: id, name: name, image: image, location: loc, musician: musician)
        
          return user
    }
} 

protocol BandDetailProviderProtocol:class{
    func providerDidFinishLoading(provider of: BandDetailProvider, band: BandDetailViewModel?)
    func providerDidLoadImage(provider of: BandDetailProvider, imageView: UIImageView, data: Data?)
    func providerDidFindChat(provider of: BandDetailProvider, chatId: String)
}

