//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

class MusiciansListViewController: UITableViewController {
    
    var provider: MusiciansListProvider! = nil
    
    private var orderOption:[MusiciansListProvider.Order]? = nil
    private var selectedOrder = [String]()
    private var orderSelection: RSSelectionMenu<String>?
    
    @IBAction func order(_ sender: Any) {
        orderSelection!.show(style: .alert(title: "Select", action: nil, height: nil), from: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = MusiciansListProvider()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicianCellItem", for: indexPath)
        //get band related to table row position
        let musicianViewModel = self.provider.getMusicianViewModel(row: indexPath.row, section: indexPath.section)
        
        if let userCell = cell as? MusiciansTableViewCell {
            if let user = musicianViewModel {
                userCell.musicianCellFormat(user: user)
            }
            return userCell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMusicianSegue" {
            if let musicianViewController = segue.destination as? MusiciansDetailViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    let item = self.provider.getMusicianViewModel(row: indexPath.row, section: indexPath.section)
                    musicianViewController.id = item!.id
                }
            }
        }
        if segue.identifier == "ShowMusicianFilters" {
            
            if let navigationController = segue.destination as? UINavigationController {
                if let musicianFilterViewController = navigationController.viewControllers.first as? MusiciansFilterViewController {
                    musicianFilterViewController.delegate = self
                    musicianFilterViewController.filter = self.provider.filters
                }
            }
        }
    }
    
    @objc func refreshData() {
        self.provider.updateBandList()
    }
    
}

extension MusiciansListViewController: MusiciansListProviderProtocol {
    func providerDidFinishUpdatedDataset(provider of: MusiciansListProvider) {
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }
}

extension MusiciansListViewController: MusiciansFilterViewControllerProtocol {
    func bandFilterDone(provider of: MusiciansFilterViewController, filters: MusiciansFilterViewModel) {
        provider.filterMusicians(filters: filters)
    }
    
    func bandFilterClear(provider of: MusiciansFilterViewController) {
        provider.clearFilters()
    }
}
