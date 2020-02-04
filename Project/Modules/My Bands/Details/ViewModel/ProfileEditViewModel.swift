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
    var isMusician: Bool = false
    var musicianDescription: String?
    var musicianSkills: [Skills]?
    var musicianGenres: [Genre]?
    
    init() { }
    
    init(_ user: User) {
        self.id = user.id
        self.name = user.name
        self.image = user.image
        self.location = user.location
        self.isMusician = user.musician == nil ? false : true
        self.musicianSkills = user.musician?.skills
        self.musicianGenres = user.musician?.genres
        self.musicianDescription = user.musician?.description
    }
    
    func setNameFromView(_ name: String?) {
        self.name = name
    }
    func setMusicianFromView(_ isMusician: Bool) {
        self.isMusician = isMusician
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
    func setGenreFromView(_ genres: [String]?) {
        guard let genres = genres else { return }
        var genreList = [Genre]()
        for genre in genres {
            if let newGenre = Genre.init(rawValue: genre) {
                genreList.append(newGenre)
            }
        }
        self.musicianGenres = genreList
    }
    func setSkillFromView(_ skills: [String]?) {
        guard let skills = skills else { return }
        var skillList = [Skills]()
        for skill in skills {
            if let newSkill = Skills.init(rawValue: skill) {
                skillList.append(newSkill)
            }
        }
        self.musicianSkills = skillList
    }
    func setDescriptionFromView(_ description: String?) {
        self.musicianDescription = description
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
    func getGenreForView() -> [String]? {
        return self.musicianGenres != nil ? self.musicianGenres!.map { $0.rawValue } : nil
    }
    func getSkillForView() -> [String]? {
        return self.musicianSkills != nil ? self.musicianSkills!.map { $0.rawValue } : nil
    }
    func getDescriptionForView() -> String? {
        return self.musicianDescription
    }
    func getIsMusicianForView() -> Bool {
        return self.isMusician
    }
    
    func isFullFilled() -> Bool {
        return self.name != nil &&
               self.image != nil &&
               self.location != nil
    }
    
}
