//
//  Band.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import UIKit

class ProfileMusicianViewModel {
    
    var id: String?
    var isMusician: Bool = false
    var description: String?
    var skills: [Skills]?
    var genres: [Genre]?
    
    init() { }
    
    init(_ user: User) {
        self.id = user.id
        self.isMusician = user.musician == nil ? false : true
        self.skills = user.musician?.skills
        self.genres = user.musician?.genres
        self.description = user.musician?.description
    }
    

    func setMusicianFromView(_ isMusician: Bool) {
        self.isMusician = isMusician
    }
    func setGenreFromView(_ genres: [String]?) {
        guard let genres = genres else { return }
        var genreList = [Genre]()
        for genre in genres {
            if let newGenre = Genre.init(rawValue: genre) {
                genreList.append(newGenre)
            }
        }
        self.genres = genreList
    }
    func setSkillFromView(_ skills: [String]?) {
        guard let skills = skills else { return }
        var skillList = [Skills]()
        for skill in skills {
            if let newSkill = Skills.init(rawValue: skill) {
                skillList.append(newSkill)
            }
        }
        self.skills = skillList
    }
    func setDescriptionFromView(_ description: String?) {
        self.description = description
    }
    
    
    func getGenreForView() -> [String]? {
        return self.genres != nil ? self.genres!.map { $0.rawValue } : nil
    }
    func getSkillForView() -> [String]? {
        return self.skills != nil ? self.skills!.map { $0.rawValue } : nil
    }
    func getDescriptionForView() -> String? {
        return self.description
    }
    func getIsMusicianForView() -> Bool {
        return self.isMusician
    }
    
}
