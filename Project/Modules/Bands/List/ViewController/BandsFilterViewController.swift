//
//  BandsFilterViewController.swift
//  Jam
//
//  Created by Henri on 2019-12-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

class BandsFilterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private let genres = Genre.allCases
    private var selectedGenres = [String]()
    private var genreSelection: RSSelectionMenu<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clean(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeDistance(_ sender: Any) {
        if let slider = sender as? UISlider {
            distanceLabel.text = "\(Int(slider.value))km"
        }
    }
    
    @IBAction func tapLocation(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .ended {
            let storyboard = UIStoryboard.init(name: "MyBands", bundle: nil)
            let locationViewController = storyboard.instantiateViewController(withIdentifier: "locationVC") as! LocationMapViewController
            locationViewController.delegate = self
            self.navigationController?.pushViewController(locationViewController, animated: true)
        }
    }
    
    func configView () {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        nameTextField.delegate = self
        genreTextField.delegate = self
        locationTextField.delegate = self
        
        genreTextField.inputView = UIView()
        genreTextField.inputAccessoryView = UIView()
        locationTextField.inputView = UIView()
        locationTextField.inputAccessoryView = UIView()
        
        var selectionValues = [String]()
        for genre in genres {
            selectionValues.append(genre.rawValue)
        }
        genreSelection = RSSelectionMenu(selectionStyle: .multiple, dataSource: selectionValues) { (cell, genre, indexPath) in
            cell.textLabel?.text = genre
        }
        genreSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
            self!.selectedGenres = selectedItems
            self!.genreTextField.text = self!.selectedGenres.joined(separator: ", ")
        }
    }
}

extension BandsFilterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == genreTextField {
            genreSelection!.show(style: .popover(sourceView: genreTextField, size: nil), from: self)
        }
    }
}

extension BandsFilterViewController: LocationMapViewControllerDelegate {
    func locationDidSet(_ controller: LocationMapViewController, location: Location?) {
        navigationController?.popViewController(animated: true)
        if let location = location {
            //            self.band?.setLocationFromView(city: location.city, state: location.state, country: location.country, postalCode: location.postalCode, lat: location.lat, lng: location.lng)
            //            locationTextField.text = self.band?.getLocationForView()
        }
    }
}
