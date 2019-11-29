//
//  BandListProvider.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation


class MyBandListProvider {
    
    weak var delegate : MyBandListProviderProtocol?
    private var bands: [Band]?
    private var jsonError: ProviderError?
    
    var numberOfBands: Int {
        if let list = bands {
            return list.count
        } else {
            return 0
        }
    }
    
    enum ProviderError: Error {
        case invalidURL
        case unreacheble
        case badFormat
    }
    
    public func getBandViewModel(row withRID: Int, section withSID: Int) -> MyBandListViewModel? {
        guard let list = bands else {
            return nil
        }
        return MyBandListViewModel(list[withRID])
    }

    public func getBandIndex(indexOf band: Band) -> Int? {
        guard let list = bands else {
           return nil
        }
        return list.firstIndex(of: band)
    }

    
    public func getBand(indexOf index: Int) -> Band? {
        guard let list = bands else {
            return nil
        }
        return list[index]
    }
    
    func loadBands () {
        do {
            try loadBandsData(url: "https://www.ereditagenealogia.com/bands.json")
        } catch {
            print("Invalid URL")
        }
    }
    
    public func addBand(_ band: Band) {
        bands?.append(band)
    }
    
    public func deleteBand(at index: Int) {
        bands?.remove(at: index)
    }
     
     public func loadBandsData(url urlString: String) throws {
         let configuration = URLSessionConfiguration.ephemeral
         let session = URLSession(configuration: configuration)
         
         guard let url = URL(string: urlString) else {
             throw ProviderError.invalidURL
         }
    
         let task = session.dataTask(with: url) {
             (data, response, error) in
             
             guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                 self.jsonError = ProviderError.unreacheble
                 return
             }
             
             do {
                 try self.bands = [Band](jsonData: data);
                 OperationQueue.main.addOperation {
                     self.delegate?.providerDidFinishUpdatedDataset(provider: self)
                 }
             } catch {
                 self.jsonError = ProviderError.badFormat
             }
         }
         task.resume()
     }
    
    
}

protocol MyBandListProviderProtocol:class{
    func providerDidFinishUpdatedDataset(provider of: MyBandListProvider);
}
