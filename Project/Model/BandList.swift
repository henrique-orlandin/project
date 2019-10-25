//
//  BandList.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-22.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation

struct BandList {
    var bands = [Band]()
    
    init() {
        for index in 1...10 {
            let band = Band(
                name: "Band \(index)",
                description: "Desc \(index)",
                pictures: ["https://images-na.ssl-images-amazon.com/images/I/61xQ%2BN5lxIL._SX425_.jpg"],
                genres: [Genre.rock],
                address: Address(
                    city: "Los Angeles",
                    state: "California",
                    country: "United States",
                    lat: "-50.2352352352",
                    lng: "-23.3463463463"
                )
            )
            bands.append(band)
        }
    }
}
