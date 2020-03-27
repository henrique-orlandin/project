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

class MyAdsListProvider {
    
    weak var delegate : MyAdsListProviderProtocol?
    private var ads: [Advertising]?
    private var error: Error?
    private var loadingSubcontent: Int? = nil {
        didSet {
            if self.loadingSubcontent == 0 {
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
                self.loadingSubcontent = nil
            }
        }
    }
    
    var numberOfAds: Int {
        if let list = ads {
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
    
    public func getAdViewModel(row withRID: Int, section withSID: Int) -> MyAdsListViewModel? {
        guard let list = ads else {
            return nil
        }
        return MyAdsListViewModel(list[withRID])
    }
    
    public func getAdIndex(indexOf ad: Advertising) -> Int? {
        guard let list = self.ads else {
            return nil
        }
        return list.firstIndex(of: ad)
    }
    
    
    public func getAd(indexOf index: Int) -> Advertising? {
        guard let list = ads else {
            return nil
        }
        return list[index]
    }
    
    public func updateAd(_ ad: Advertising, at index: Int) {
        ads?[index] = ad
    }
    
    public func addAd(_ ad: Advertising) {
        ads?.append(ad)
    }
    
    
    public func deleteAd(at index: Int) {
        if let ad = ads?[index] {
            
            let db = Firestore.firestore()
            db.collection("ads").document(ad.id).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                }
                if ad.type == Advertising.AdType.band {
                    db.collection("bands").document(ad.id_band!).updateData(["advertising": false])
                } else {
                    db.collection("users").document(ad.id_user!).updateData(["advertising": false])
                }
            }
            ads?.remove(at: index)
        }
    }
    
    public func loadAds() {
        
        var adList = [Advertising]()
        
        let db = Firestore.firestore()
        db.collection("ads").whereField("id_user", isEqualTo: Auth.auth().currentUser!.uid).getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
            } else {
                self.loadingSubcontent = querySnapshot!.documents.count
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let ad = self.decode(id: document.documentID, data: data) {
                        adList.append(ad)
                    }
                }
                self.ads = adList
                self.loadSubcontentData()
            }
        })
    }
    
    public func loadSubcontentData() {
        
        let db = Firestore.firestore()
        if let ads = ads {
            for (index, ad) in ads.enumerated() {
                var collection:String
                var refId: String
                var updatedAd: Advertising = ad
                
                if ad.type == Advertising.AdType.band {
                    collection = "bands"
                    refId = ad.id_band!
                } else {
                    collection = "users"
                    refId = ad.id_user!
                }
                
                db.collection(collection).document(refId).getDocument(completion: {
                    document, error in
                    if let error = error {
                        self.error = error
                        self.delegate?.providerDidFinishUpdatedDataset(provider: self)
                    } else  if
                        let bandDocument = document,
                        let data = bandDocument.data() {
                        if ad.type == Advertising.AdType.band {
                            let band = self.decodeBand(id: bandDocument.documentID, data: data)
                            updatedAd.band = band
                        } else {
                            let user = self.decodeUser(id: bandDocument.documentID, data: data)
                            updatedAd.user = user
                        }
                        self.ads?[index] = updatedAd
                    }
                    self.loadingSubcontent = self.loadingSubcontent! - 1
                })
            }
        }
        
    }
    
    func decode(id: String, data:[String: Any]) -> Advertising? {
        
        guard let type = data["type"] as? String, let notify = data["notify"] as? Bool else {
            return nil
        }
        
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
        
        let adType = type == "band" ? Advertising.AdType.band : Advertising.AdType.musician
        
        let ad = Advertising(id: id, type: adType, notify: notify, id_user: id_user, id_band: id_band, user: nil, band: nil, genre: genreList, skills: skillList, location: loc)
        
        return ad
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

protocol MyAdsListProviderProtocol:class{
    func providerDidFinishUpdatedDataset(provider of: MyAdsListProvider)
}
