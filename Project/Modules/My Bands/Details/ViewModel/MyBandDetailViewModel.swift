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
    
    var id: Int?
    var name: String?
    var genre: [Genre]?
    var pictures: [String]?
    var location: String?
    var description: String?
    
    init() { }
    
    init(_ band: Band) {
        self.id = band.id
        self.pictures = band.pictures
        self.genre = band.genres
        self.name = band.name
        self.location = band.address.city
        self.description = band.description
    }
    
    func setNameFromView(_ name: String?) {
        self.name = name
    }
    func setGenreFromView(_ genre: String?) {
        guard let genre = genre else { return }
        if let newGenre = Genre.init(rawValue: genre) {
            self.genre?.append(newGenre)
        }
    }
    func setPicturesFromView(_ picture: UIImage?) {
        guard let picture = picture else { return }
        if let imageData:Data = picture.pngData() {
            let image64 = imageData.base64EncodedString(options: .lineLength64Characters)
            self.pictures?.append(image64)
        }
    }
    func setLocationFromView(_ location: String?) {
        self.location = location
    }
    func setDescriptionFromView(_ description: String?) {
        self.description = description
    }
    
    
    func getNameForView() -> String? {
        return self.name
    }
    func getGenreForView() -> String? {
        if let genre = self.genre?[0] {
            return genre.rawValue
        } else {
            return nil
        }
    }
    func getPicturesForView() -> String? {
        guard let image = self.pictures?[0] else {
            return nil
        }
        
//        let dataDecoded: Data = Data(base64Encoded: image, options: .ignoreUnknownCharacters)!
//        let decodedImage = UIImage(data: dataDecoded)
//        return decodedImage
        return image
        
    }
    func getLocationForView() -> String? {
        return self.location
    }
    func getDescriptionForView() -> String? {
        return self.description
    }
    
    func isFullFilled() -> Bool {
        return self.name != nil &&
               self.genre != nil &&
               self.location != nil &&
               self.pictures != nil &&
               self.description != nil
    }
    
}
