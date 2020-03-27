//
//  BandListProvider.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

@objc class BandListProvider: NSObject {
    
    weak var delegate : BandListProviderProtocol?
    
    private var bandList: [BandListViewModel]?
    public var filters: BandFilterViewModel?
    private var bands: [Band]?
    public var error: Error?
    public var orderOptions = Order.allCases
    private var currentOrderColumn = "name"
    private var currentOrder = "asc"
    
    var numberOfBands: Int {
        if let list = bandList {
            return list.count
        } else {
            return 0
        }
    }
    
    enum Order: String, CaseIterable {
        case nameASC = "Name Ascendently"
        case nameDESC = "Name Descendently"
        case genreASC = "Genre Ascendently"
        case genreDESC = "Genre Descendently"
        func returnColumn() -> (String, String) {
            switch self {
            case .nameASC:
                return ("name", "asc")
            case .nameDESC:
                return ("name", "desc")
            case .genreASC:
                return ("genre", "asc")
            case .genreDESC:
                return ("genre", "desc")
            }
        }
    }
    
    func setOrder(order: String) {
        if let order = Order(rawValue: order) {
            let (column, order) = order.returnColumn()
            currentOrder = order
            currentOrderColumn = column
            updateBandList()
        }
    }
    
    func loadImage(image: String, to imageView: UIImageView) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("bands/\(image)")
        imagesRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else if let data = data, let image = UIImage(data: data) {
                self.delegate?.providerDidLoadImage?(provider: self, image: image, imageView: imageView)
            }
        }
    }
    
    private func getGeopointRange (
        latitude: Double,
        longitude: Double,
        distance: Double
    ) -> (GeoPoint, GeoPoint){
        
        let distance = distance * 0.621371
        
        let lat = 0.0144927536231884; // degrees latitude per mile
        let lon = 0.0181818181818182; // degrees longitude per mile
        
        let lowerLat = latitude - lat * distance;
        let lowerLon = longitude - lon * distance;
        
        let upperLat = latitude + lat * distance;
        let upperLon = longitude + lon * distance;
        
        let lowerGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
        let upperGeopoint = GeoPoint(latitude: upperLat, longitude: upperLon)
        
        return (
            lowerGeopoint,
            upperGeopoint
        );
    };
    
    public func clearFilters() {
        var bandList = [BandListViewModel]()
        self.filters = nil
        if let bands = self.bands {
            for band in bands {
                bandList.append(BandListViewModel(band))
            }
        }
        self.bandList = bandList
        self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
    }
    
    public func filterBands(filters: BandFilterViewModel) {
        
        var bandList = [BandListViewModel]()
        self.filters = filters
        if var bands = self.bands {
            if let location = filters.location, let locationDistance = filters.locationDistance {
                let (lowerGeopoint, upperGeopoint) = getGeopointRange(latitude: location.lat, longitude: location.lng, distance: Double(locationDistance))
                bands = bands.filter({(band:Band) -> Bool in
                    let geo = GeoPoint(latitude: band.location.lat, longitude: band.location.lng)
                    return geo.latitude > lowerGeopoint.latitude && geo.longitude > lowerGeopoint.longitude && geo.latitude < upperGeopoint.latitude && geo.longitude < upperGeopoint.longitude
                })
            }
            if let genres = filters.genre {
                bands = bands.filter({(band:Band) -> Bool in
                    for genre in genres {
                        return band.genres.contains(genre)
                    }
                    return false
                })
            }
            if let name = filters.name {
                bands = bands.filter({(band:Band) -> Bool in
                    return band.name.contains(name)
                })
            }
            let advertising = filters.advertising
            if advertising {
                bands = bands.filter({(band:Band) -> Bool in
                    return band.advertising == advertising
                })
            }
            for band in bands {
                bandList.append(BandListViewModel(band))
            }
        }
        self.bandList = bandList
        self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
    }
    
    public func getBandViewModel(row withRID: Int, section withSID: Int) -> BandListViewModel? {
        guard let list = bandList else {
            return nil
        }
        
        return list[withRID]
    }
    
    public func updateBandList() {
        
        var bandList = [BandListViewModel]()
        var bands = [Band]()
        
        let db = Firestore.firestore()
        db.collection("bands").order(by: currentOrderColumn, descending: currentOrder == "desc").getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let band = self.decode(id: document.documentID, data: data) {
                        bandList.append(BandListViewModel(band))
                        bands.append(band)
                    }
                }
                self.bandList = bandList
                self.bands = bands
                if let filters = self.filters {
                    self.filterBands(filters: filters)
                }
                self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
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
        
        var advertising = false
        if let ad = data["advertising"] as? Bool {
            advertising = ad
        }
        
        let band = Band(id: id, name: name, image: image, description: description, genres: genreList, location: loc, gallery: nil, reviews: nil, contact: nil, videos: nil, audios: nil, links: nil, musicians: nil, advertising: advertising)
        
        return band
    }
}

@objc protocol BandListProviderProtocol:class{
    @objc optional func providerDidFinishUpdatedDataset(provider of: BandListProvider);
    @objc optional func providerDidLoadImage(provider of: BandListProvider, image: UIImage, imageView: UIImageView)
}
