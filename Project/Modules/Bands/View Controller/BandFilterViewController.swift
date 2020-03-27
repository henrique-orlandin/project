//
//  BandsFilterViewController.swift
//  Jam
//
//  Created by Henri on 2019-12-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

class BandFilterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var advertisingSwitch: UISwitch!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var distanceStack: UIStackView!
    
    private let genres = Genre.allCases
    private var selectedGenres = [String]()
    private var genreSelection: RSSelectionMenu<String>?
    
    weak var delegate: BandFilterViewControllerProtocol?
    public var filter: BandFilterViewModel! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
        
        if filter != nil {
            editConfig()
        } else {
            filter = BandFilterViewModel()
            filter.setLocationDistanceFromView(distance: 50)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.bandFilterDone(provider: self, filters: filter)
    }
    
    @IBAction func clean(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.bandFilterClear(provider: self)
        filter = nil
        nameTextField.text = ""
        genreSelection = nil
        selectedGenres = []
        locationTextField.text = ""
        distanceLabel.text = "50Km"
        distanceSlider.value = 50.0
        advertisingSwitch.isOn = false
    }
    
    @IBAction func advertising(_ sender: Any) {
        filter?.setAdvertisingFromView(advertising: advertisingSwitch.isOn)
    }
    
    @IBAction func changeDistance(_ sender: Any) {
        if let slider = sender as? UISlider {
            distanceLabel.text = "\(Int(slider.value))km"
            filter?.setLocationDistanceFromView(distance: Int(slider.value))
        }
    }
    
    @IBAction func tapLocation(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .ended {
            locationTextField.becomeFirstResponder()
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let locationViewController = storyboard.instantiateViewController(withIdentifier: "locationVC") as! LocationMapViewController
            locationViewController.delegate = self
            self.navigationController?.pushViewController(locationViewController, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameTextField.loadLine()
        genreTextField.loadLine()
        locationTextField.loadLine()
    }
    
    func configView () {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        nameTextField.delegate = self
        nameTextField.defaultLayout()
        genreTextField.delegate = self
        genreTextField.defaultLayout()
        locationTextField.delegate = self
        locationTextField.defaultLayout()
        
        cleanButton.defaultLayout()
        
        nameTextField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        
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
            self!.filter?.setGenreFromView(selectedItems)
        }
        
        distanceStack.isHidden = true
    }
    
    @objc func nameDidChange() {
        self.filter?.setNameFromView(nameTextField.text)
    }
    
    func editConfig() {
        if let filter = filter {
            nameTextField.text = filter.getNameForView()
            if let selectedGenres = filter.getGenreForView() {
                self.selectedGenres = selectedGenres
                genreTextField.text = selectedGenres.joined(separator: ", ")
                genreSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
                    self!.selectedGenres = selectedItems
                    self!.genreTextField.text = self!.selectedGenres.joined(separator: ", ")
                    self!.filter?.setGenreFromView(selectedItems)
                }
            }
            
            if let location = filter.getLocationForView() {
                locationTextField.text = location
                distanceStack.isHidden = false
            }
            
            if let distance = filter.getLocationDistanceForView() {
                distanceLabel.text = "\(distance)Km"
                distanceSlider.value = Float(distance)
            }
            
            advertisingSwitch.isOn = filter.getAdvertisingForView()
        }
    }
}

extension BandFilterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == genreTextField {
            genreSelection!.show(style: .popover(sourceView: genreTextField, size: nil), from: self)
            textField.resignFirstResponder()
        }
    }
}

extension BandFilterViewController: LocationMapViewControllerDelegate {
    func locationDidSet(_ controller: LocationMapViewController, location: Location?) {
        navigationController?.popViewController(animated: true)
        if let location = location {
            filter.setLocationFromView(city: location.city, state: location.state, country: location.country, postalCode: location.postalCode, lat: location.lat, lng: location.lng)
            locationTextField.text = filter.getLocationForView()
            distanceStack.isHidden = false
        }
    }
}

protocol BandFilterViewControllerProtocol:class{
    func bandFilterDone(provider of: BandFilterViewController, filters: BandFilterViewModel);
    func bandFilterClear(provider of: BandFilterViewController);
}
