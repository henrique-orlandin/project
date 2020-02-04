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
    
    public func loadBand(_ id: String) throws {
        
        let db = Firestore.firestore()
        db.collection("bands").document(id).getDocument(completion: {
            document, error in
            if let error = error {
                self.error = error
            } else if
                let document = document,
                let data = document.data(),
                let band = self.decode(id: document.documentID, data: data) {
                    self.band = BandDetailViewModel(band)
            } else {
                self.error = ProviderError.decodeError
            }
            self.delegate?.providerDidFinishLoading(provider: self, band: self.band)
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

protocol BandDetailProviderProtocol:class{
    func providerDidFinishLoading(provider of: BandDetailProvider, band: BandDetailViewModel?)
    func providerDidLoadImage(provider of: BandDetailProvider, imageView: UIImageView, data: Data?)
}

