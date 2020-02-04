//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

class BandListViewController: UITableViewController {
    
    var provider: BandListProvider! = nil
    
    private var orderOption:[BandListProvider.Order]? = nil
    private var selectedOrder = [String]()
    private var orderSelection: RSSelectionMenu<String>?
    
   
    @IBAction func order(_ sender: Any) {
        orderSelection!.show(style: .alert(title: "Select", action: nil, height: nil), from: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = BandListProvider()
        self.provider.delegate = self
        self.provider.updateBandList()
        orderOption = self.provider.orderOptions
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshData), for: .valueChanged)
        self.refreshControl = refreshControl
        
        var selectionValues = [String]()
        for option in orderOption! {
            selectionValues.append(option.rawValue)
        }
        orderSelection = RSSelectionMenu(dataSource: selectionValues) { (cell, order, indexPath) in
            cell.textLabel?.text = order
        }
        orderSelection!.setSelectedItems(items: selectedOrder) { [weak self] (item, index, isSelected, selectedItems) in
            self!.selectedOrder = selectedItems
            self!.provider.setOrder(order: selectedItems.first!);
        }
        
    }
    
    //return the number of rows for this table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.provider.numberOfBands
    }
    
    //executed for each cell on the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "BandCellItem", for: indexPath)
        //get band related to table row position
        let bandViewModel = self.provider.getBandViewModel(row: indexPath.row, section: indexPath.section)
        
        if let bandCell = cell as? BandTableViewCell {
            if let band = bandViewModel {
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
            if let bandViewController = segue.destination as? BandDetailViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    let item = self.provider.getBandViewModel(row: indexPath.row, section: indexPath.section)
                    bandViewController.id = item!.id
                }
            }
        }
        if segue.identifier == "showFilters" {
            
            if let navigationController = segue.destination as? UINavigationController {
                if let bandFilterViewController = navigationController.viewControllers.first as? BandFilterViewController {
                    bandFilterViewController.delegate = self
                    bandFilterViewController.filter = self.provider.filters
                }
            }
        }
    }
    
    @objc func refreshData() {
        self.provider.updateBandList()
    }
    
}

extension BandListViewController: BandListProviderProtocol {
    func providerDidFinishUpdatedDataset(provider of: BandListProvider) {
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
}

extension BandListViewController: BandFilterViewControllerProtocol {
    func bandFilterDone(provider of: BandFilterViewController, filters: BandFilterViewModel) {
        provider.filterBands(filters: filters)
    }
    
    func bandFilterClear(provider of: BandFilterViewController) {
        provider.clearFilters()
    }
}
