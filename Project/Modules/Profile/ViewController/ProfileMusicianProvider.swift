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

class ProfileMusicianProvider {
    
    weak var delegate : ProfileMusicianProviderProtocol?
    public var error: Error?
    private var user: User?
    
    enum ProviderError: Error {
        case decodeError
    }
    
    public func loadProfile() throws {
        
        let db = Firestore.firestore()
        var userDetail:ProfileMusicianViewModel?
        if let id = Auth.auth().currentUser?.uid {
            db.collection("users").document(id).getDocument(completion: {
                document, error in
                if let error = error {
                    self.error = error
                } else if
                    let document = document,
                    let data = document.data(),
                    let user = self.decode(id: document.documentID, data: data) {
                    userDetail = ProfileMusicianViewModel(user)
                    self.user = user
                } else {
                    self.error = ProviderError.decodeError
                }
                self.delegate?.providerDidLoadProfile(provider: self, profile: userDetail)
            })
        }
    }
    
    
    func saveData(_ profile: ProfileMusicianViewModel) {
        
        let uid = profile.id!
        
        let data = self.encode(profile: profile)
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData(data, completion: {
            (error) in
            if let error = error {
                self.delegate?.providerDidFinishSavingProfile(provider: self, error: error.localizedDescription)
            }
            else {
                self.delegate?.providerDidFinishSavingProfile(provider: self)
            }
        })
    }
    
    func decode(id: String, data:[String: Any]) -> User? {
        
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
    
    func encode(profile: ProfileMusicianViewModel) -> [String:Any] {
        
        var data:[String: Any] = [
            "is_musician": profile.isMusician
        ]
        
        if profile.isMusician {
            if let description = profile.description {
                data["description"] = description
            }
            
            var genres = [String]()
            for genre in profile.genres! {
                genres.append(genre.rawValue)
            }
            data["genre"] = genres
            
            var skills = [String]()
            for skill in profile.skills! {
                skills.append(skill.rawValue)
            }
            data["skills"] = skills
        }
        
        return data
    }
    
}


protocol ProfileMusicianProviderProtocol:class {
    func providerDidFinishSavingProfile(provider of: ProfileMusicianProvider, error: String)
    func providerDidFinishSavingProfile(provider of: ProfileMusicianProvider)
    func providerDidLoadProfile(provider of: ProfileMusicianProvider, profile: ProfileMusicianViewModel?)
}
