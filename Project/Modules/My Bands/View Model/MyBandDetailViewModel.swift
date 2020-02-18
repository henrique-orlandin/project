//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import UIKit

class MyBandDetailViewModel: Decodable {
    
    var id: String?
    var name: String?
    var genre: [Genre]?
    var image: String?
    var gallery: [String]?
    var location: Location?
    var description: String?
    
    init() { }
    
    init(_ band: Band) {
        self.id = band.id
        self.image = band.image
        self.genre = band.genres
        self.name = band.name
        self.location = band.location
        self.gallery = band.gallery
        self.description = band.description
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
    func setPicturesFromView(_ picture: UIImage?) {
        guard let picture = picture else { return }
        if let imageData:Data = picture.pngData() {
            self.image = imageData.base64EncodedString(options: .lineLength64Characters)
        }
    }
    func setLocationFromView(city: String?, state: String?, country: String?, postalCode: String?, lat: Double?, lng: Double?) {
        guard
            let lat = lat,
            let lng = lng
            else { return }
        
        self.location = Location(city: city, state: state, country: country, postalCode: postalCode, lat: lat, lng: lng)
    }
    func setDescriptionFromView(_ description: String?) {
        self.description = description
    }
    
    
    func getNameForView() -> String? {
        return self.name
    }
    func getGenreForView() -> [String]? {
        return self.genre != nil ? self.genre!.map { $0.rawValue } : nil
    }
    func getPicturesForView() -> String? {
        return self.image
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
    func getDescriptionForView() -> String? {
        return self.description
    }
    
    func isFullFilled() -> Bool {
        return self.name != nil &&
               self.genre != nil &&
               self.location != nil &&
               self.image != nil &&
               self.description != nil
    }
    
}
