//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import UIKit

class MyAdsDetailViewModel {
    
    var id: String?
    var type = Advertising.AdType.band
    var notify = true
    var id_user: String?
    var id_band: String?
    var user: User?
    var band: Band?
    var genre: [Genre]?
    var skill: [Skills]?
    var location: Location?
    
    init() { }
    
    init(_ ad: Advertising) {
        self.id = ad.id
        self.type = ad.type
        self.notify = ad.notify
        self.id_user = ad.id_user
        self.id_band = ad.id_band
        self.genre = ad.genre
        self.skill = ad.skills
        self.user = ad.user
        self.band = ad.band
        self.location = ad.location
    }
    
    func setTypeFromView(_ type: Advertising.AdType?) {
        guard let type = type else { return }
        self.type = type
    }
    func setGenreFromView(_ genres: [String]?) {
        guard let genres = genres else { return }
        var genreList = [Genre]()
        for genre in genres {
            if let newGenre = Genre.init(rawValue: genre) {
                genreList.append(newGenre)
            }
        }
        self.genre = genreList.count > 0 ? genreList : nil
    }
    func setSkillsFromView(_ skills: [String]?) {
        guard let skills = skills else { return }
        var skillList = [Skills]()
        for skill in skills {
            if let newSkill = Skills.init(rawValue: skill) {
                skillList.append(newSkill)
            }
        }
        self.skill = skillList.count > 0 ? skillList : nil
    }
    func setLocationFromView(city: String?, state: String?, country: String?, postalCode: String?, lat: Double?, lng: Double?) {
        guard
            let lat = lat,
            let lng = lng
            else {
                self.location = nil
                return
        }
        
        self.location = Location(city: city, state: state, country: country, postalCode: postalCode, lat: lat, lng: lng)
    }
    func setMusicianFromView(_ musician: User?) {
        self.user = musician
    }
    func setBandFromView(_ band: Band?) {
        self.band = band
    }
    func setNotifyFromView(_ notify: Bool) {
        self.notify = notify
    }
    
    
    func getTypeForView() -> Advertising.AdType? {
        return self.type
    }
    func getGenreForView() -> [String]? {
        return self.genre != nil ? self.genre!.map { $0.rawValue } : nil
    }
    func getSkillForView() -> [String]? {
        return self.skill != nil ? self.skill!.map { $0.rawValue } : nil
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
        return string.joined(separator: ", ")
    }
    func getBandForView() -> Band? {
        return self.band
    }
    func getNotifyForView() -> Bool {
        return self.notify
    }
}
