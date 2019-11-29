//
//  BandListProvider.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation


class MyBandDetailProvider {
    
    weak var delegate : MyBandDetailProviderProtocol?
    
    private var bandDetail: MyBandDetailViewModel?
    private var jsonError: ProviderError?
    
    
    enum ProviderError: Error {
        case invalidURL
        case unreacheble
        case badFormat
    }
    
    func saveBand(_ band: MyBandDetailViewModel) {
        
        print(band)
        let json = """
        {
            'name' : 'My band',
            'genre' : 'Rock',
            'location' : 'Vancouver',
            'description' : 'This is the description',
            'image' : 'http://ppcorn.com/us/wp-content/uploads/sites/14/2016/01/Led-Zeppelin-pop-art-ppcorn.jpg',
        }
        """
        
        let url = URL(string: "http://httpbin.org/post")!
        var request = URLRequest(url: url)

        request.httpMethod = "Post"
        request.httpBody = json.data(using: .utf8)

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) {
            (data, request, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let band = try decoder.decode(Band.self, from: data)
                    OperationQueue.main.addOperation {
                        self.delegate?.providerDidFinishAddingBand(provider: self, band: band)
                    }
                    
                } catch {
                    let address = Address(address: nil, city: "Vancouver", state: "BC", country: "Canada", complement: nil, lat: nil, lng: nil, zipcode: nil)
                    let id = band.id != nil ? band.id! : 12
                    let tempBand = Band(id: id, name: "My band", description: "This is the description", pictures: ["http://ppcorn.com/us/wp-content/uploads/sites/14/2016/01/Led-Zeppelin-pop-art-ppcorn.jpg"], genres: [.rock], address: address, reviews: nil, contact: nil, videos: nil, audios: nil, links: nil, musicians: nil)
                    OperationQueue.main.addOperation {
                        if band.id == nil {
                            self.delegate?.providerDidFinishAddingBand(provider: self, band: tempBand)
                        } else {
                            self.delegate?.providerDidFinishEditingBand(provider: self, band: tempBand)
                        }
                    }
                }
            }
        }
        task.resume()
        
    }
    
}


protocol MyBandDetailProviderProtocol:class {
    func providerDidFinishAddingBand(provider of: MyBandDetailProvider, band: Band);
    func providerDidFinishEditingBand(provider of: MyBandDetailProvider, band: Band);
}
