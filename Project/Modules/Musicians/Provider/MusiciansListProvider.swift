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

@objc class MusiciansListProvider: NSObject {
    
    weak var delegate : MusiciansListProviderProtocol?
    
    private var musiciansList: [MusiciansListViewModel]?
    public var filters: MusiciansFilterViewModel?
    private var musicians: [User]?
    public var error: Error?
    public var orderOptions = Order.allCases
    private var currentOrderColumn = "name"
    private var currentOrder = "asc"
    
    var numberOfBands: Int {
        if let list = musiciansList {
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
        let imagesRef = storageRef.child("users/\(image)")
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
        var musiciansList = [MusiciansListViewModel]()
        self.filters = nil
        if let musicians = self.musicians {
            for musician in musicians {
                musiciansList.append(MusiciansListViewModel(musician))
            }
        }
        self.musiciansList = musiciansList
        self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
    }
    
    public func filterMusicians(filters: MusiciansFilterViewModel) {
        
        var musiciansList = [MusiciansListViewModel]()
        self.filters = filters
        if var musicians = self.musicians {
            if let location = filters.location, let locationDistance = filters.locationDistance {
                let (lowerGeopoint, upperGeopoint) = getGeopointRange(latitude: location.lat, longitude: location.lng, distance: Double(locationDistance))
                musicians = musicians.filter({(musician:User) -> Bool in
                    let geo = GeoPoint(latitude: musician.location!.lat, longitude: musician.location!.lng)
                    return geo.latitude > lowerGeopoint.latitude && geo.longitude > lowerGeopoint.longitude && geo.latitude < upperGeopoint.latitude && geo.longitude < upperGeopoint.longitude
                })
            }
            if let genres = filters.genre {
                musicians = musicians.filter({(user:User) -> Bool in
                    for genre in genres {
                        return user.musician!.genres.contains(genre)
                    }
                    return false
                })
            }
            if let skills = filters.skills {
                musicians = musicians.filter({(user:User) -> Bool in
                    for skill in skills {
                        return user.musician!.skills.contains(skill)
                    }
                    return false
                })
            }
            if let name = filters.name {
                musicians = musicians.filter({(musician:User) -> Bool in
                    return musician.name.contains(name)
                })
            }
            let advertising = filters.advertising
            if advertising {
                musicians = musicians.filter({(user:User) -> Bool in
                    return user.musician!.advertising == advertising
                })
            }
            for musician in musicians {
                musiciansList.append(MusiciansListViewModel(musician))
            }
        }
        self.musiciansList = musiciansList
        self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
    }
    
    public func getMusicianViewModel(row withRID: Int, section withSID: Int) -> MusiciansListViewModel? {
        guard let list = musiciansList else {
            return nil
        }
        
        return list[withRID]
    }
    
    public func updateBandList() {
        
        var musiciansList = [MusiciansListViewModel]()
        var musicians = [User]()
        
        let db = Firestore.firestore()
        db.collection("users").whereField("is_musician", isEqualTo: true).order(by: currentOrderColumn, descending: currentOrder == "desc").getDocuments(completion: {
            querySnapshot, error in
            if let error = error {
                self.error = error
                self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let musician = self.decode(id: document.documentID, data: data) {
                        musiciansList.append(MusiciansListViewModel(musician))
                        musicians.append(musician)
                    }
                }
                self.musiciansList = musiciansList
                self.musicians = musicians
                if let filters = self.filters {
                    self.filterMusicians(filters: filters)
                }
                self.delegate?.providerDidFinishUpdatedDataset?(provider: self)
            }
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
        
        var advertising = false
        if let ad = data["advertising"] as? Bool {
            advertising = ad
        }
          
          var musician: Musician? = nil
          if isMusician != nil, isMusician == true, let desc = description {
              musician = Musician(description: desc, genres: genreList, skills: skillList, gallery: nil, reviews: nil, contact: nil, videos: nil, audios: nil, links: nil, advertising: advertising)
          }
          let user = User(id: id, name: name, image: image, location: loc, musician: musician)
        
          return user
    }
}

@objc protocol MusiciansListProviderProtocol:class{
    @objc optional func providerDidFinishUpdatedDataset(provider of: MusiciansListProvider);
    @objc optional func providerDidLoadImage(provider of: MusiciansListProvider, image: UIImage, imageView: UIImageView)
}
