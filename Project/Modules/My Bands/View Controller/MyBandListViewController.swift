//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

class MyBandListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, MyBandListProviderProtocol {
    
    var provider: MyBandListProvider! = nil
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func addButtonAction(_ sender: Any) {
        if isEditing {
            setEditing(false, animated: true)
            let icon = UIImage.fontAwesomeIcon(name: .plus, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
            addButton.setImage(icon, for: .normal)
            
            let indexPaths = collectionView.indexPathsForVisibleItems
            for indexPath in indexPaths {
                let cell = collectionView.cellForItem(at: indexPath) as! MyBandCollectionViewCell
                cell.isInEditingMode = false
            }
        } else {
            let storyboard = UIStoryboard.init(name: "MyBands", bundle: nil)
            let details = storyboard.instantiateViewController(withIdentifier: "MyBandsDetailsVC") as! MyBandDetailViewController
            details.delegate = self
            self.navigationController?.pushViewController(details, animated: true)
        }
    }

    func providerDidFinishUpdatedDataset(provider of: MyBandListProvider) {
        self.view.removeSpinner()
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = MyBandListProvider()
        self.provider.delegate = self
        self.provider.loadBands()
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
            let cell = collectionView.cellForItem(at: indexPath) as! MyBandCollectionViewCell
            cell.isInEditingMode = true
        }
        
        let icon = UIImage.fontAwesomeIcon(name: .times, style: .solid, textColor: .white, size: CGSize(width: 30, height: 30))
        addButton.setImage(icon, for: .normal)
    }
    
    
    //return the number of rows for this table
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider.numberOfBands
    }
    
    //executed for each cell on the table
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get the reusable cell with identifier BandCellItem
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyBandCellItem", for: indexPath)
        //get band related to table row position
        let bandViewModel = self.provider.getBandViewModel(row: indexPath.row, section: indexPath.section)
        
        if let bandCell = cell as? MyBandCollectionViewCell {
            bandCell.delegate = self
            bandCell.band = provider.getBand(indexOf: indexPath.row)
            if let band = bandViewModel {
                bandCell.bandCellFormat(band: band)
            }
            return bandCell
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 125)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !isEditing
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editBandSegue" {
            if let myBandViewController = segue.destination as? MyBandDetailViewController,
                let cell = sender as? UICollectionViewCell,
                let indexPath = collectionView.indexPath(for: cell),
                let band = self.provider.getBand(indexOf: indexPath.row) {
                
                myBandViewController.id = band.id
                myBandViewController.delegate = self
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
        collectionView.insertItems(at: [indexPath])
    }

    func bandDetailViewController(_ controller: MyBandDetailViewController, didFinishEditing band: Band) {
        navigationController?.popViewController(animated: true)
        if let index = provider.getBandIndex(indexOf: band) {
            let indexPath = IndexPath(row: index, section: 0)
            provider.updateBand(band, at: index)
            if let cell = collectionView.cellForItem(at: indexPath) as? MyBandCollectionViewCell {
                cell.bandCellFormat(band: MyBandListViewModel(band))
            }
        }
    }
}


extension MyBandListViewController: MyBandCollectionViewCellDelegate {
    func removeCell(_ controller: MyBandCollectionViewCell, band: Band?) {
        if let band = band, let index = provider.getBandIndex(indexOf: band) {
            let indexPath = IndexPath(row: index, section: 0)
            provider.deleteBand(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
        }
    }
}
