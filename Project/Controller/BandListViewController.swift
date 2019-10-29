//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class BandListViewController: UITableViewController {

    var bands = [Band]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            bands = try [Band](fileName: "bands")
        } catch {
            print("\(error)")
        }
    }
    
    //return the number of rows for this table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bands.count
    }
    
    //executed for each cell on the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "BandCellItem", for: indexPath)
        //get band related to table row position
        let band = bands[indexPath.row]
        
        if let bandCell = cell as? BandTableViewCell {
            bandCell.bandCellFormat(band: band)
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
                    let item = bands[indexPath.row]
                    bandViewController.band = item
                }
            }
        }
    }
    
}
