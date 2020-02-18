//
//  BandsFilterViewController.swift
//  Jam
//
//  Created by Henri on 2019-12-30.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

class MusiciansFilterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var advertisingSwitch: UISwitch!
    
    private let genres = Genre.allCases
    private var selectedGenres = [String]()
    private var genreSelection: RSSelectionMenu<String>?
    
    private let skills = Skills.allCases
    private var selectedSkills = [String]()
    private var skillsSelection: RSSelectionMenu<String>?
    
    weak var delegate: MusiciansFilterViewControllerProtocol?
    public var filter: MusiciansFilterViewModel! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
        
        if filter != nil {
            editConfig()
        } else {
            filter = MusiciansFilterViewModel()
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
    
    @IBAction func changeDistance(_ sender: Any) {
        if let slider = sender as? UISlider {
            distanceLabel.text = "\(Int(slider.value))km"
            filter?.setLocationDistanceFromView(distance: Int(slider.value))
        }
    }
    
    @IBAction func advertising(_ sender: Any) {
        filter?.setAdvertisingFromView(advertising: advertisingSwitch.isOn)
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
    
    func configView () {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        nameTextField.delegate = self
        genreTextField.delegate = self
        skillsTextField.delegate = self
        locationTextField.delegate = self
        
        nameTextField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        
        genreTextField.inputView = UIView()
        genreTextField.inputAccessoryView = UIView()
        skillsTextField.inputView = UIView()
        skillsTextField.inputAccessoryView = UIView()
        locationTextField.inputView = UIView()
        locationTextField.inputAccessoryView = UIView()
        
        var selectionGenreValues = [String]()
        for genre in genres {
            selectionGenreValues.append(genre.rawValue)
        }
        genreSelection = RSSelectionMenu(selectionStyle: .multiple, dataSource: selectionGenreValues) { (cell, genre, indexPath) in
            cell.textLabel?.text = genre
        }
        genreSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
            self!.selectedGenres = selectedItems
            self!.genreTextField.text = self!.selectedGenres.joined(separator: ", ")
            self!.filter?.setGenreFromView(selectedItems)
        }
        
        var selectionSkillsValues = [String]()
        for skill in skills {
            selectionSkillsValues.append(skill.rawValue)
        }
        skillsSelection = RSSelectionMenu(selectionStyle: .multiple, dataSource: selectionSkillsValues) { (cell, skill, indexPath) in
            cell.textLabel?.text = skill
        }
        skillsSelection!.setSelectedItems(items: selectedSkills) { [weak self] (item, index, isSelected, selectedItems) in
            self!.selectedSkills = selectedItems
            self!.skillsTextField.text = self!.selectedSkills.joined(separator: ", ")
            self!.filter?.setSkillsFromView(selectedItems)
        }
    }
    
    @objc func nameDidChange() {
        self.filter?.setNameFromView(nameTextField.text)
    }
    
    func editConfig() {
        if let filter = filter {
            nameTextField.text = filter.getNameForView()
            if let selectedGenres = filter.getGenreForView() {
                genreTextField.text = selectedGenres.joined(separator: ", ")
                self.selectedGenres = selectedGenres
                genreSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
                    self!.selectedGenres = selectedItems
                    self!.genreTextField.text = selectedItems.joined(separator: ", ")
                    self!.filter?.setGenreFromView(selectedItems)
                }
            }
            if let selectedSkills = filter.getSkillsForView() {
                self.selectedSkills = selectedSkills
                skillsTextField.text = selectedSkills.joined(separator: ", ")
                skillsSelection!.setSelectedItems(items: selectedSkills) { [weak self] (item, index, isSelected, selectedItems) in
                    self!.selectedSkills = selectedItems
                    self!.skillsTextField.text = self!.selectedSkills.joined(separator: ", ")
                    self!.filter?.setSkillsFromView(selectedItems)
                }
            }
            locationTextField.text = filter.getLocationForView()
            if let distance = filter.getLocationDistanceForView() {
                distanceLabel.text = "\(distance)Km"
                distanceSlider.value = Float(distance)
            }
            advertisingSwitch.isOn = filter.getAdvertisingForView()
        }
    }
}

extension MusiciansFilterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == genreTextField {
            genreSelection!.show(style: .popover(sourceView: genreTextField, size: nil), from: self)
            textField.resignFirstResponder()
        }
        if textField == skillsTextField {
            skillsSelection!.show(style: .popover(sourceView: skillsTextField, size: nil), from: self)
            textField.resignFirstResponder()
        }
    }
}

extension MusiciansFilterViewController: LocationMapViewControllerDelegate {
    func locationDidSet(_ controller: LocationMapViewController, location: Location?) {
        navigationController?.popViewController(animated: true)
        if let location = location {
            filter.setLocationFromView(city: location.city, state: location.state, country: location.country, postalCode: location.postalCode, lat: location.lat, lng: location.lng)
            locationTextField.text = filter.getLocationForView()
        }
    }
}

protocol MusiciansFilterViewControllerProtocol:class{
    func bandFilterDone(provider of: MusiciansFilterViewController, filters: MusiciansFilterViewModel);
    func bandFilterClear(provider of: MusiciansFilterViewController);
}
