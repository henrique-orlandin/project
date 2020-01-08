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

class MyBandListProvider {
    
    weak var delegate : MyBandListProviderProtocol?
    private var bands: [Band]?
    private var error: Error?
    
    var numberOfBands: Int {
        if let list = bands {
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
    
    public func getBandViewModel(row withRID: Int, section withSID: Int) -> MyBandListViewModel? {
        guard let list = bands else {
            return nil
        }
        return MyBandListViewModel(list[withRID])
    }
    
    public func getBandIndex(indexOf band: Band) -> Int? {
        guard let list = bands else {
            return nil
        }
        return list.firstIndex(of: band)
    }
    
    
    public func getBand(indexOf index: Int) -> Band? {
        guard let list = bands else {
            return nil
        }
        return list[index]
    }
    
    public func updateBand(_ band: Band, at index: Int) {
        bands?[index] = band
    }
    
    public func addBand(_ band: Band) {
        bands?.append(band)
    }
    
    public func deleteBand(at index: Int) {
        if let band = bands?[index] {
            let db = Firestore.firestore()
            db.collection("bands").document(band.id).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                }
            }
            bands?.remove(at: index)
        }
    }
    
    public func loadBands() {
        
        var bandList = [Band]()
        
        let db = Firestore.firestore()
        db.collection("bands").whereField("id_user", isEqualTo: Auth.auth().currentUser!.uid).getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let band = self.decode(id: document.documentID, data: data) {
                        bandList.append(band)
                    }
                }
                self.bands = bandList
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
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
    
    
}

protocol MyBandListProviderProtocol:class{
    func providerDidFinishUpdatedDataset(provider of: MyBandListProvider);
}
