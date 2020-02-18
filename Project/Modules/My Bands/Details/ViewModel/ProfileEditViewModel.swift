//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import UIKit

class ProfileEditViewModel {
    
    var id: String?
    var name: String?
    var image: String?
    var location: Location?
    
    init() { }
    
    init(_ user: User) {
        self.id = user.id
        self.name = user.name
        self.image = user.image
        self.location = user.location
    }
    
    func setNameFromView(_ name: String?) {
        self.name = name
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
    
    
    func getNameForView() -> String? {
        return self.name
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

    
    func isFullFilled() -> Bool {
        return self.name != nil &&
               self.image != nil &&
               self.location != nil
    }
    
}
