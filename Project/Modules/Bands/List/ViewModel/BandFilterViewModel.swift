//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class BandFilterViewModel {
    
    var name: String?
    var genre: [Genre]?
    var location: Location?
    var locationDistance: Int?
    
    init() {
        
    }
    
    init(_ band: Band) {
        self.name = band.name
        self.genre = band.genres
        self.location = band.location
    }
    
    func setNameFromView(_ name: String?) {
        self.name = name
    }
    func setGenreFromView(_ genres: [String]?) {
        guard let genres = genres else { return }
        var genreList = [Genre]()
        for genre in genres {
            if let newGenre = Genre.init(rawValue: genre) {
                genreList.append(newGenre)
            }
        }
        self.genre = genreList
    }
    func setLocationFromView(city: String?, state: String?, country: String?, postalCode: String?, lat: Double?, lng: Double?) {
        guard
            let lat = lat,
            let lng = lng
            else { return }
        
        self.location = Location(city: city, state: state, country: country, postalCode: postalCode, lat: lat, lng: lng)
    }
    
    func setLocationDistanceFromView(distance: Int?) {
        guard let distance = distance else { return }
        self.locationDistance = distance
    }
    
    func getNameForView() -> String? {
        return self.name
    }
    func getGenreForView() -> [String]? {
        return self.genre != nil ? self.genre!.map { $0.rawValue } : nil
    }
    func getLocationForView() -> String? {
        guard let location = self.location else {
            return nil
        }
        var string = [String]()
        if let city = location.city {
            string.append(city)
        }
        if let state = location.state {
            string.append(state)
        }
        if let country = location.country {
            string.append(country)
        }
        if let postalCode = location.postalCode {
            string.append(postalCode)
        }
        return string.joined(separator: ", ")
    }
    func getLocationDistanceForView() -> Int? {
        return self.locationDistance
    }
}
