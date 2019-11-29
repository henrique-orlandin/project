//
//  BandListProvider.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation


class BandListProvider {
    
    weak var delegate : BandListProviderProtocol?
    
    private var bandList: [BandListViewModel]?
    private var bandDetail: [BandDetailViewModel]?
    private var jsonError: ProviderError?
    
    var numberOfBands: Int {
        if let list = bandList {
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
    
    public func getBandViewModel(row withRID: Int, section withSID: Int) -> BandListViewModel? {
        updateBandList()
        guard let list = bandList else {
            return nil
        }
        return list[withRID]
    }
    
    public func getBandDetailViewModel(row withRID: Int, section withSID: Int) -> BandDetailViewModel? {
        updateBandList()
        guard let list = bandDetail else {
            return nil
        }
        return list[withRID]
    }
    
    public func updateBandList() {
        if bandList == nil {
            do {
                try loadBands(url: "https://www.ereditagenealogia.com/bands.json")
            } catch {
                print("Invalid URL")
            }
        }
    }
    
    public func loadBands(url urlString: String) throws {
        
        var bands = [Band]()
        
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
                try bands = [Band](jsonData: data);
                self.bandList = bands.map { BandListViewModel($0) }
                self.bandDetail = bands.map { BandDetailViewModel($0) }
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

protocol BandListProviderProtocol:class{
    func providerDidFinishUpdatedDataset(provider of: BandListProvider);
}
