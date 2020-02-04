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

class MyBandDetailProvider {
    
    weak var delegate : MyBandDetailProviderProtocol?
    public var error: Error?
    private var band: Band?
    
    enum ProviderError: Error {
        case decodeError
    }
    
    public func loadBand(_ id: String) throws {
        
        let db = Firestore.firestore()
        var bandDetail:MyBandDetailViewModel?
        db.collection("bands").document(id).getDocument(completion: {
            document, error in
            if let error = error {
                self.error = error
            } else if
                let document = document,
                let data = document.data(),
                let band = self.decode(id: document.documentID, data: data) {
                bandDetail = MyBandDetailViewModel(band)
                self.band = band
            } else {
                self.error = ProviderError.decodeError
            }
            self.delegate?.providerDidLoadBand(provider: self, band: bandDetail)
        })
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
    
    func saveBand(_ band: MyBandDetailViewModel) {
        
        let uid = band.id ?? UUID().uuidString
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageName = "\(uid).png"
        let imagesRef = storageRef.child("bands/\(imageName)")
        
        if let decodedData = Data(base64Encoded: band.image!, options: .ignoreUnknownCharacters) {
            imagesRef.putData(decodedData, metadata: nil) { metadata, error in
                if let error = error {
                    print(error)
                } else {
                    band.image = imageName
                    var data = self.encode(band: band)
                    let db = Firestore.firestore()
                    data["id"] = uid
                    
                    db.collection("bands").document(uid).setData(data, completion: {
                        (error) in
                        if let error = error {
                            self.delegate?.providerDidFinishSavingBand(provider: self, error: error.localizedDescription)
                        }
                        else {
                            db.collection("bands").document(uid).getDocument(completion: {
                                snapshot, error in
                                if let error = error {
                                    self.delegate?.providerDidFinishSavingBand(provider: self, error: error.localizedDescription)
                                } else {
                                    if let snapshot = snapshot {
                                        if let response = snapshot.data(),
                                            let newBand = self.decode(id: uid, data: response) {
                                            self.delegate?.providerDidFinishSavingBand(provider: self, band: newBand)
                                        }
                                    }
                                }
                            })
                        }
                    })
                }
            }
            
        }
        
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
    
    func encode(band: MyBandDetailViewModel) -> [String:Any] {
        
        let geopoint = GeoPoint(latitude: band.location!.lat, longitude: band.location!.lng)
        
        var data:[String: Any] = [
            "name": band.name!,
            "image": band.image!,
            "description": band.description!,
            "id_user": Auth.auth().currentUser!.uid
        ]
        
        var location: [String: Any] = [
            "lat_lng": geopoint
        ]
        if let city = band.location!.city {
            location["city"] = city
        }
        if let state = band.location!.state {
            location["state"] = state
        }
        if let country = band.location!.country {
            location["country"] = country
        }
        if let postalCode = band.location!.postalCode {
            location["postal_code"] = postalCode
        }
        data["location"] = location
        
        var genres = [String]()
        for genre in band.genre! {
            genres.append(genre.rawValue)
        }
        data["genre"] = genres
        
        return data
    }
    
}


protocol MyBandDetailProviderProtocol:class {
    func providerDidFinishSavingBand(provider of: MyBandDetailProvider, error: String)
    func providerDidFinishSavingBand(provider of: MyBandDetailProvider, band: Band)
    func providerDidLoadBand(provider of: MyBandDetailProvider, band: MyBandDetailViewModel?)
    func providerDidLoadImage(provider of: MyBandDetailProvider, imageView: UIImageView, data: Data?)
}
