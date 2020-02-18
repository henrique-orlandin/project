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

class MyAdsDetailProvider {
    
    weak var delegate : MyAdsDetailProviderProtocol?
    public var error: Error?
    private var ad: MyAdsDetailViewModel?
    private var bands: [Band]?
    private var user: User?
    
    enum ProviderError: Error {
        case decodeError
    }
    
    public func loadBands() {
        
        var bandList = [Band]()
        
        let db = Firestore.firestore()
        db.collection("bands").whereField("id_user", isEqualTo: Auth.auth().currentUser!.uid).getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishLoadingBands(provider: self, bands: self.bands)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let band = self.decodeBand(id: document.documentID, data: data) {
                        bandList.append(band)
                    }
                }
                self.bands = bandList
                self.delegate?.providerDidFinishLoadingBands(provider: self, bands: self.bands)
            }
        })
    }
    
    public func loadAd(_ id: String) throws {
        
        let db = Firestore.firestore()
        var adDetail:MyAdsDetailViewModel?
        var band: Band?
        var user: User?
        db.collection("ads").document(id).getDocument(completion: {
            document, error in
            if let error = error {
                self.error = error
            } else if
                let adDocument = document,
                let adData = adDocument.data(),
                let type = adData["type"] as? String {
                if type == "band" {
                    let id_band = adData["id_band"] as! String
                    db.collection("bands").document(id_band).getDocument(completion: {
                        document, error in
                        if let error = error {
                            self.error = error
                        } else if
                            let document = document,
                            let data = document.data() {
                            band = self.decodeBand(id: document.documentID, data: data)
                            if var ad = self.decode(id: adDocument.documentID, data: adData) {
                                ad.band = band
                                adDetail = MyAdsDetailViewModel(ad)
                                self.ad = adDetail
                            }
                        }
                        self.delegate?.providerDidLoadAd(provider: self, ad: adDetail)
                    })
                } else {
                    db.collection("users").document(Auth.auth().currentUser!.uid).getDocument(completion: {
                        document, error in
                        if let error = error {
                            self.error = error
                        } else if
                            let document = document,
                            let data = document.data() {
                            user = self.decodeUser(id: document.documentID, data: data)
                            if var ad = self.decode(id: adDocument.documentID, data: adData) {
                                ad.user = user
                                adDetail = MyAdsDetailViewModel(ad)
                                self.ad = adDetail
                            }
                        }
                        self.delegate?.providerDidLoadAd(provider: self, ad: adDetail)
                    })
                }
                
            } else {
                self.error = ProviderError.decodeError
            }
        })
    }
    
    public func loadUser() {
        
        let db = Firestore.firestore()
        if let id = Auth.auth().currentUser?.uid {
            db.collection("users").document(id).getDocument(completion: {
                document, error in
                if let error = error {
                    self.error = error
                } else if
                    let document = document,
                    let data = document.data(),
                    let user = self.decodeUser(id: document.documentID, data: data) {
                    self.user = user
                } 
                self.delegate?.providerDidFinishLoadingUser(provider: self, user: self.user)
            })
        }
    }
    
    func saveAd(_ ad: MyAdsDetailViewModel) {
        
        let uid = ad.id ?? UUID().uuidString
        
        var data = self.encode(ad: ad)
        let db = Firestore.firestore()
        data["id"] = uid
        
        db.collection("ads").document(uid).setData(data, completion: {
            (error) in
            if let error = error {
                self.delegate?.providerDidFinishSavingAd(provider: self, error: error.localizedDescription)
            }
            else {
                
                if ad.type == Advertising.AdType.band, let id_band = ad.id_band {
                    db.collection("bands").document(id_band).updateData(["advertising": true])
                } else {
                    db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["advertising": true])
                }
                
                db.collection("ads").document(uid).getDocument(completion: {
                    snapshot, error in
                    if let error = error {
                        self.delegate?.providerDidFinishSavingAd(provider: self, error: error.localizedDescription)
                    } else {
                        if let snapshot = snapshot {
                            if let response = snapshot.data(),
                                var newAd = self.decode(id: uid, data: response) {
                                newAd.band = ad.band
                                newAd.user = ad.user
                                self.delegate?.providerDidFinishSavingAd(provider: self, ad: newAd)
                            }
                        }
                    }
                })
            }
        })
    }
    
    func decode(id: String, data:[String: Any]) -> Advertising? {
        
        guard
            let type = data["type"] as? String,
            let notify = data["notify"] as? Bool
            else {
                return nil
        }
        
        let adType = type == "band" ? Advertising.AdType.band : Advertising.AdType.musician
        let id_user = data["id_user"] as? String ?? nil
        let id_band = data["id_band"] as? String ?? nil
        
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
        
        let ad = Advertising(id: id, type: adType, notify: notify, id_user: id_user, id_band: id_band, user: nil, band: nil, genre: genreList, skills: skillList, location: loc)
        
        return ad
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
    
    func encode(ad: MyAdsDetailViewModel) -> [String:Any] {
        
        var data:[String: Any] = [
            "type": ad.type == Advertising.AdType.band ? "band" : "musician",
            "id_user": Auth.auth().currentUser!.uid,
            "notify": ad.notify
        ]
        
        if let band = ad.band, ad.type == Advertising.AdType.band {
            data["id_band"] = band.id
        }

        if let loc = ad.location, ad.notify {
            let geopoint = GeoPoint(latitude: loc.lat, longitude: loc.lng)
            var location: [String: Any] = [
                "lat_lng": geopoint
            ]
            if let city = loc.city {
                location["city"] = city
            }
            if let state = loc.state {
                location["state"] = state
            }
            if let country = loc.country {
                location["country"] = country
            }
            if let postalCode = loc.postalCode {
                location["postal_code"] = postalCode
            }
            data["location"] = location
        }
        
            
        if let genres = ad.genre, ad.notify {
            var genreList = [String]()
            for genre in genres {
                genreList.append(genre.rawValue)
            }
            data["genre"] = genreList
        }
        
        if let skills = ad.skill, ad.notify {
            var skillList = [String]()
            for skill in skills {
                skillList.append(skill.rawValue)
            }
            data["skills"] = skillList
        }
        
        return data
    }
    
}


protocol MyAdsDetailProviderProtocol:class {
    func providerDidFinishSavingAd(provider of: MyAdsDetailProvider, error: String)
    func providerDidFinishSavingAd(provider of: MyAdsDetailProvider, ad: Advertising)
    func providerDidLoadAd(provider of: MyAdsDetailProvider, ad: MyAdsDetailViewModel?)
    func providerDidFinishLoadingUser(provider of: MyAdsDetailProvider, user: User?)
    func providerDidFinishLoadingBands(provider of: MyAdsDetailProvider, bands: [Band]?)
}
