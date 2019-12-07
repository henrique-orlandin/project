//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class MyBandListViewController: UITableViewController, MyBandListProviderProtocol {
    
    var provider: MyBandListProvider! = nil
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBAction func addItem(_ sender: Any) {
        let newRowIndex = provider.numberOfBands
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    @IBAction func deleteItems(_ sender: Any) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for indexPath in selectedRows {
                let rowToDelete = indexPath.row > provider.numberOfBands - 1 ? provider.numberOfBands - 1 : indexPath.row
                provider.deleteBand(at: rowToDelete)
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .automatic)
            tableView.endUpdates()
        }
    }

    func providerDidFinishUpdatedDataset(provider of: MyBandListProvider) {
        self.tableView.reloadData()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = MyBandListProvider()
        self.provider.delegate = self
        self.provider.loadBands()
        
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsMultipleSelectionDuringEditing = true
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        provider.deleteBand(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //return the number of rows for this table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return bands.count
        return self.provider.numberOfBands
    }
    
    //executed for each cell on the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyBandCellItem", for: indexPath)
        //get band related to table row position
        let bandViewModel = self.provider.getBandViewModel(row: indexPath.row, section: indexPath.section)
        
        if let bandCell = cell as? MyBandTableViewCell {
            if let band = bandViewModel {
                bandCell.bandCellFormat(band: band)
            }
            return bandCell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBandSegue" {
            if let myBandViewController = segue.destination as? MyBandDetailViewController {
                myBandViewController.delegate = self
            }
        } else if segue.identifier == "editBandSegue" {
            if let myBandViewController = segue.destination as? MyBandDetailViewController {
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let band = self.provider.getBand(indexOf: indexPath.row) {
                    myBandViewController.band = MyBandDetailViewModel(band)
                    myBandViewController.delegate = self
                }
            }
        }
    }
    
}

extension MyBandListViewController: MyBandDetailViewControllerDelegate {
    
    func bandDetailViewControllerDidCancel(_ controller: MyBandDetailViewController) {
        navigationController?.popViewController(animated: true)
    }

    func bandDetailViewController(_ controller: MyBandDetailViewController, didFinishAdding band: Band) {
        navigationController?.popViewController(animated: true)
        provider.addBand(band)
        let rowIndex = provider.numberOfBands
        let indexPath = IndexPath(row: rowIndex - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func bandDetailViewController(_ controller: MyBandDetailViewController, didFinishEditing band: Band) {
        if let index = provider.getBandIndex(indexOf: band) {
            let indexPath = IndexPath(row: index, section: 0)
            provider.updateBand(band, at: index)
            if let cell = tableView.cellForRow(at: indexPath), let bandCell = cell as? MyBandTableViewCell {
                bandCell.bandCellFormat(band: MyBandListViewModel(band))
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

