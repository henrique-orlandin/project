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

class MusiciansDetailProvider {
    
    weak var delegate : MusiciansDetailProviderProtocol?
    
    private var musician: MusiciansDetailViewModel?
    public var error: Error?
    
    enum ProviderError: Error {
        case decodeError
    }
    
    public func getMusician() -> MusiciansDetailViewModel? {
        guard let item = musician else {
            return nil
        }
        return item
    }
    
    func loadImage(image: String, to imageView: UIImageView) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("users/\(image)")
        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                self.delegate?.providerDidLoadImage(provider: self, imageView: imageView, data: nil)
            } else {
                self.delegate?.providerDidLoadImage(provider: self, imageView: imageView, data: data)
            }
        }
    }
    
    public func loadUser(_ id: String) throws {
        
        let db = Firestore.firestore()
        db.collection("users").document(id).getDocument(completion: {
            document, error in
            if let error = error {
                self.error = error
            } else if
                let document = document,
                let data = document.data(),
                let musician = self.decode(id: document.documentID, data: data) {
                    self.musician = MusiciansDetailViewModel(musician)
            } else {
                self.error = ProviderError.decodeError
            }
            self.delegate?.providerDidFinishLoading(provider: self, musician: self.musician)
        })
    }
    
    func decode(id: String, data:[String: Any]) -> User? {
        
        guard
            let name = data["name"] as? String
            else {
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

protocol MusiciansDetailProviderProtocol:class{
    func providerDidFinishLoading(provider of: MusiciansDetailProvider, musician: MusiciansDetailViewModel?)
    func providerDidLoadImage(provider of: MusiciansDetailProvider, imageView: UIImageView, data: Data?)
}

