//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class MyAdsListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, MyAdsListProviderProtocol {
    
    var provider: MyAdsListProvider! = nil
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func addItem(_ sender: Any) {
        if isEditing {
            stopDeleting()
        } else {
            let storyboard = UIStoryboard.init(name: "Ads", bundle: nil)
            let details = storyboard.instantiateViewController(withIdentifier: "AdsDetailsVC") as! MyAdsDetailViewController
            details.delegate = self
            self.navigationController?.pushViewController(details, animated: true)
        }
    }

    func providerDidFinishUpdatedDataset(provider of: MyAdsListProvider) {
        self.view.removeSpinner()
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = MyAdsListProvider()
        self.provider.delegate = self
        self.provider.loadAds()
        self.view.showSpinner(onView: self.view)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let icon = UIImage.fontAwesomeIcon(name: .plus, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
        addButton.setImage(icon, for: .normal)
        addButton.defaultLayout()
        addButton.layer.cornerRadius = addButton.frame.height / 2
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressGR)
    }
    
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .began {
            return
        }
        
        setEditing(true, animated: true)
        
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! MyAdsCollectionViewCell
            cell.isInEditingMode = true
        }
        
        let icon = UIImage.fontAwesomeIcon(name: .times, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
        addButton.setImage(icon, for: .normal)
    }

    //return the number of rows
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider.numberOfAds
    }
    
    //executed for each cell on the table
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyAdsCellItem", for: indexPath)
        let adViewModel = self.provider.getAdViewModel(row: indexPath.row, section: indexPath.section)
        
        if let adCell = cell as? MyAdsCollectionViewCell {
            if let ad = adViewModel {
                adCell.ad = provider.getAd(indexOf: indexPath.row)
                adCell.delegate = self
                adCell.adCellFormat(ad: ad) 
            }
            return adCell
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 105)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !isEditing
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let myAdViewController = segue.destination as? MyAdsDetailViewController {
            if let cell = sender as? UICollectionViewCell,
                let indexPath = collectionView.indexPath(for: cell),
                let ad = self.provider.getAd(indexOf: indexPath.row) {
                myAdViewController.id = ad.id
                myAdViewController.delegate = self
            }
        }
    
    }
    
    func stopDeleting() {
        setEditing(false, animated: true)
        let icon = UIImage.fontAwesomeIcon(name: .plus, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
        addButton.setImage(icon, for: .normal)
        
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! MyAdsCollectionViewCell
            cell.isInEditingMode = false
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
        collectionView.insertItems(at: [indexPath])
    }

    func adDetailViewController(_ controller: MyAdsDetailViewController, didFinishEditing ad: Advertising) {
        if let index = provider.getAdIndex(indexOf: ad) {
            let indexPath = IndexPath(row: index, section: 0)
            provider.updateAd(ad, at: index)
            if let cell = collectionView.cellForItem(at: indexPath) as? MyAdsCollectionViewCell {
                cell.adCellFormat(ad: MyAdsListViewModel(ad))
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

extension MyAdsListViewController: MyAdsCollectionViewCellDelegate {
    func removeCell(_ controller: MyAdsCollectionViewCell, ad: Advertising?) {
        if let ad = ad, let index = provider.getAdIndex(indexOf: ad) {
            let indexPath = IndexPath(row: index, section: 0)
            provider.deleteAd(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        }
        if provider.numberOfAds == 0 {
            stopDeleting()
        }
    }
}
