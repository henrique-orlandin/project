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

class ProfileProvider {
    
    weak var delegate : ProfileProviderProtocol?
    public var error: Error?
    private var user: User?
    
    enum ProviderError: Error {
        case decodeError
    }
    
    public func loadProfile() throws {
        
        let db = Firestore.firestore()
        var userDetail:ProfileEditViewModel?
        if let id = Auth.auth().currentUser?.uid {
            db.collection("users").document(id).getDocument(completion: {
                document, error in
                if let error = error {
                    self.error = error
                } else if
                    let document = document,
                    let data = document.data(),
                    let user = self.decode(id: document.documentID, data: data) {
                    userDetail = ProfileEditViewModel(user)
                    self.user = user
                } else {
                    self.error = ProviderError.decodeError
                }
                self.delegate?.providerDidLoadProfile(provider: self, profile: userDetail)
            })
        }
    }
    
    func loadImage(image: String, to imageView: UIImageView) {
        
        guard let user = user else {
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("users/\(user.image!)")
        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                self.delegate?.providerDidLoadImage(provider: self, imageView: imageView, data: nil)
            } else {
                self.delegate?.providerDidLoadImage(provider: self, imageView: imageView, data: data)
            }
        }
    }
    
    func saveData(_ profile: ProfileEditViewModel) {
        
        let uid = profile.id!
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageName = "\(uid).png"
        let imagesRef = storageRef.child("users/\(imageName)")
        
        if let image = profile.image, let decodedData = Data(base64Encoded: image, options: .ignoreUnknownCharacters) {
            imagesRef.putData(decodedData, metadata: nil) { metadata, error in
                if let error = error {
                    print(error)
                } else {
                    profile.image = imageName
                    self.saveProfileData(id: uid, profile: profile)
                }
            }
        } else {
            self.saveProfileData(id: uid, profile: profile)
        }
    }
    
    func saveProfileData (id: String, profile: ProfileEditViewModel) {
        let data = self.encode(profile: profile)
        let db = Firestore.firestore()
        db.collection("users").document(id).updateData(data, completion: {
            (error) in
            if let error = error {
                self.delegate?.providerDidFinishSavingProfile(provider: self, error: error.localizedDescription)
            }
            else {
                db.collection("users").document(id).getDocument(completion: {
                    snapshot, error in
                    if let error = error {
                        self.delegate?.providerDidFinishSavingProfile(provider: self, error: error.localizedDescription)
                    } else {
                        if let snapshot = snapshot {
                            if let response = snapshot.data(),
                                let newUser = self.decode(id: id, data: response) {
                                self.delegate?.providerDidFinishSavingProfile(provider: self, profile: newUser)
                            }
                        }
                    }
                })
            }
        })
    }
    
    func saveLocation (_ location: Location) {
        let data = self.encodeLocation(locationData: location)
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(data, completion: {
            (error) in
            if let error = error {
                print(error)
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
    
    func encode(profile: ProfileEditViewModel) -> [String:Any] {
        
        let geopoint = GeoPoint(latitude: profile.location!.lat, longitude: profile.location!.lng)
        
        var data:[String: Any] = [
            "name": profile.name!,
        ]
        
        if let image = profile.image {
            data["image"] = image
        }
        
        var location: [String: Any] = [
            "lat_lng": geopoint
        ]
        if let city = profile.location!.city {
            location["city"] = city
        }
        if let state = profile.location!.state {
            location["state"] = state
        }
        if let country = profile.location!.country {
            location["country"] = country
        }
        if let postalCode = profile.location!.postalCode {
            location["postal_code"] = postalCode
        }
        data["location"] = location
        
        return data
    }
    
    func encodeLocation(locationData: Location) -> [String:Any] {
        
        let geopoint = GeoPoint(latitude: locationData.lat, longitude: locationData.lng)
        
        var data = [String: Any]()
        
        var location: [String: Any] = [
            "lat_lng": geopoint
        ]
        if let city = locationData.city {
            location["city"] = city
        }
        if let state = locationData.state {
            location["state"] = state
        }
        if let country = locationData.country {
            location["country"] = country
        }
        if let postalCode = locationData.postalCode {
            location["postal_code"] = postalCode
        }
        data["location"] = location
        
        return data
    }
    
}


protocol ProfileProviderProtocol:class {
    func providerDidFinishSavingProfile(provider of: ProfileProvider, error: String)
    func providerDidFinishSavingProfile(provider of: ProfileProvider, profile: User)
    func providerDidLoadProfile(provider of: ProfileProvider, profile: ProfileEditViewModel?)
    func providerDidLoadImage(provider of: ProfileProvider, imageView: UIImageView, data: Data?)
}
