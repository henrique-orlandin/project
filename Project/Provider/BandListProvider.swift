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
    
    private var bandList: [BandViewModel]?
    private var bandDetail: [BandDetailViewModel]?
    
    var numberOfBands: Int {
        updateBandList()
        return bandList!.count
    }
    
    public func getBandViewModel(row withRID: Int, section withSID: Int) -> BandViewModel? {
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
            var bands = [Band]()
            do {
                bands = try [Band](fileName: "bands")
                //bands = try [Band](url: "https://www.ereditagenealogia.com/bands.json")
                bandList = bands.map { BandViewModel($0) }
                bandDetail = bands.map { BandDetailViewModel($0) }
                self.delegate?.providerDidFinishUpdatedDataset(provider: self)
            } catch {
                print("\(error)")
            }
        }
    }
    
}

protocol BandListProviderProtocol:class{
    func providerDidFinishUpdatedDataset(provider of: BandListProvider);
}
