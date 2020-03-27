//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu
import FontAwesome_swift

class BandListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var provider: BandListProvider! = nil
    
    private var orderOption:[BandListProvider.Order]? = nil
    private var selectedOrder = [String]()
    private var orderSelection: RSSelectionMenu<String>?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var orderButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
   
    @IBAction func order(_ sender: Any) {
        orderSelection!.show(style: .alert(title: "Select", action: nil, height: nil), from: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.provider = BandListProvider()
        self.provider.delegate = self
        self.provider.updateBandList()
        orderOption = self.provider.orderOptions
        
        self.view.showSpinner(onView: self.view)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
        
        let orderIcon = UIImage.fontAwesomeIcon(name: .sort, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
        orderButton.image = orderIcon
        
        let filterIcon = UIImage.fontAwesomeIcon(name: .slidersH, style: .solid, textColor: .white, size: CGSize(width: 25, height: 25))
        filterButton.image = filterIcon
        filterButton.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10);
        
    }
    
    //return the number of rows for this table
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.provider.numberOfBands
    }
    
    //executed for each cell on the table
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BandCellItem", for: indexPath)
        //get band related to table row position
        let bandViewModel = self.provider.getBandViewModel(row: indexPath.row, section: indexPath.section)
        
        if let bandCell = cell as? BandCollectionViewCell {
            if let band = bandViewModel {
                bandCell.bandCellFormat(band: band)
            }
            return bandCell
        }
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBandSegue" {
            if let bandViewController = segue.destination as? BandDetailViewController {
                if let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
    
}

extension BandListViewController: BandListProviderProtocol {
    func providerDidFinishUpdatedDataset(provider of: BandListProvider) {
        self.collectionView.reloadData()
        self.view.removeSpinner()
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
