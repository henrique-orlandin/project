//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandListViewController: UITableViewController, BandListProviderProtocol {
    
    func providerDidFinishUpdatedDataset(provider of: BandListProvider) {
        self.tableView.reloadData()
    }

    //var bands = [Band]()
    
    var provider: BandListProvider! = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = BandListProvider()
        self.provider.delegate = self
        self.provider.updateBandList()
    }
    
    //return the number of rows for this table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return bands.count
        return self.provider.numberOfBands
    }
    
    //executed for each cell on the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "BandCellItem", for: indexPath)
        //get band related to table row position
        
        let bandViewModel = self.provider.getBandViewModel(row: indexPath.row, section: indexPath.section)
        
        
        if let bandCell = cell as? BandTableViewCell {
            if let band=bandViewModel {
                bandCell.bandCellFormat(band: band)
            }
            return bandCell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBandSegue" {
            if let bandViewController = segue.destination as? BandViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    let item = self.provider.getBandViewModel(row: indexPath.row, section: indexPath.section)
                    //let item = bands[indexPath.row]
                    bandViewController.band = item
                }
            }
        }
    }
    
}
