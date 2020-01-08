//
//  BandListProvider.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import FirebaseFirestore

class BandListProvider {
    
    weak var delegate : BandListProviderProtocol?
    
    private var bandList: [BandListViewModel]?
    private var bandFilteredList: [BandListViewModel]?
    private var isFiltered = false
    public var error: Error?
    
    var numberOfBands: Int {
        if isFiltered {
            if let list = bandFilteredList {
                return list.count
            } else {
                return 0
            }
        } else {
            if let list = bandList {
                return list.count
            } else {
                return 0
            }
        }
    }
    
    public func filterBands(withName search: String) {
        
        var bandList = [BandListViewModel]()
        
        let db = Firestore.firestore()
        db.collection("bands").whereField("name", isEqualTo: search).getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
            } else {
                self.isFiltered = true
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let band = self.decode(id: document.documentID, data: data) {
                        bandList.append(BandListViewModel(band))
                    }
                }
                self.bandFilteredList = bandList
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
            }
        })
    }
    
    public func getBandViewModel(row withRID: Int, section withSID: Int) -> BandListViewModel? {
        guard let list = bandList else {
            return nil
        }
        
        if isFiltered, let filtered = bandFilteredList {
            return filtered[withRID]
        }
        
        return list[withRID]
    }
    
    public func updateBandList() throws {
        
        var bandList = [BandListViewModel]()
        
        let db = Firestore.firestore()
        db.collection("bands").getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
            } else {
                self.isFiltered = false
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let band = self.decode(id: document.documentID, data: data) {
                        bandList.append(BandListViewModel(band))
                    }
                }
                self.bandList = bandList
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

protocol BandListProviderProtocol:class{
    func providerDidFinishUpdatedDataset(provider of: BandListProvider);
}
