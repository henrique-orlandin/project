//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class MyAdsListViewController: UITableViewController, MyAdsListProviderProtocol {
    
    var provider: MyAdsListProvider! = nil
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBAction func addItem(_ sender: Any) {
        let newRowIndex = provider.numberOfAds
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func providerDidFinishUpdatedDataset(provider of: MyAdsListProvider) {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = MyAdsListProvider()
        self.provider.delegate = self
        self.provider.loadAds()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        provider.deleteAd(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    //return the number of rows for this table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return bands.count
        return self.provider.numberOfAds
    }
    
    //executed for each cell on the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyAdsCellItem", for: indexPath)
        //get band related to table row position
        let adViewModel = self.provider.getAdViewModel(row: indexPath.row, section: indexPath.section)
        
        if let adCell = cell as? MyAdsTableViewCell {
            if let ad = adViewModel {
                adCell.adCellFormat(ad: ad)
            }
            return adCell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAdSegue" {
            if let myAdViewController = segue.destination as? MyAdsDetailViewController {
                myAdViewController.delegate = self
            }
        } else if segue.identifier == "editAdSegue" {
            if let myAdViewController = segue.destination as? MyAdsDetailViewController {
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let ad = self.provider.getAd(indexOf: indexPath.row) {
                    myAdViewController.id = ad.id
                    myAdViewController.delegate = self
                }
            }
        }
    }
    
}

extension MyAdsListViewController: MyAdsDetailViewControllerDelegate {
    func adDetailViewControllerDidCancel(_ controller: MyAdsDetailViewController) {
        navigationController?.popViewController(animated: true)
    }

    func adDetailViewController(_ controller: MyAdsDetailViewController, didFinishAdding ad: Advertising) {
        navigationController?.popViewController(animated: true)
        provider.addAd(ad)
        let rowIndex = provider.numberOfAds
        let indexPath = IndexPath(row: rowIndex - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func adDetailViewController(_ controller: MyAdsDetailViewController, didFinishEditing ad: Advertising) {
        if let index = provider.getAdIndex(indexOf: ad) {
            let indexPath = IndexPath(row: index, section: 0)
            provider.updateAd(ad, at: index)
            if let cell = tableView.cellForRow(at: indexPath), let adCell = cell as? MyAdsTableViewCell {
                adCell.adCellFormat(ad: MyAdsListViewModel(ad))
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
