//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

class MusiciansFilterViewModel {
    
    var name: String?
    var genre: [Genre]?
    var skills: [Skills]?
    var location: Location?
    var locationDistance: Int?
    var advertising: Bool = false
    
    init() {
        
    }
    
    init(_ band: User) {
        self.name = band.name
        self.genre = band.musician!.genres
        self.skills = band.musician!.skills
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
    func setSkillsFromView(_ skills: [String]?) {
        guard let skills = skills else { return }
        var skillsList = [Skills]()
        for skill in skills {
            if let newSkill = Skills.init(rawValue: skill) {
                skillsList.append(newSkill)
            }
        }
        self.skills = skillsList
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
    func setAdvertisingFromView(advertising: Bool?) {
        guard let advertising = advertising else { return }
        self.advertising = advertising
    }
    
    func getNameForView() -> String? {
        return self.name
    }
    func getGenreForView() -> [String]? {
        return self.genre != nil ? self.genre!.map { $0.rawValue } : nil
    }
    func getSkillsForView() -> [String]? {
        return self.skills != nil ? self.skills!.map { $0.rawValue } : nil
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
    func getAdvertisingForView() -> Bool {
        return self.advertising
    }
}
