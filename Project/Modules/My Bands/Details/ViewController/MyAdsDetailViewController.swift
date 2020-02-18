//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

protocol MyAdsDetailViewControllerDelegate: class {
    func adDetailViewControllerDidCancel(_ controller: MyAdsDetailViewController)
    func adDetailViewController(_ controller: MyAdsDetailViewController, didFinishAdding ad: Advertising)
    func adDetailViewController(_ controller: MyAdsDetailViewController, didFinishEditing ad: Advertising)
}

class MyAdsDetailViewController: UIViewController {

    weak var delegate: MyAdsDetailViewControllerDelegate?
    public var id: String?
    private var bands: [Band]! = nil
    private var user: User! = nil
    private var ad: MyAdsDetailViewModel! = nil
    private var provider: MyAdsDetailProvider! = nil
    
    private var pickerData: [String] = [String]()
    private var keyboardShow = false
    
    private let skills = Skills.allCases
    private var selectedSkills = [String]()
    private var skillsSelection: RSSelectionMenu<String>?
    
    private let genres = Genre.allCases
    private var selectedGenres = [String]()
    private var genreSelection: RSSelectionMenu<String>?
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var bandsPicker: UIPickerView!
    @IBOutlet weak var switchTypeFirstLabel: UILabel!
    @IBOutlet weak var switchTypeSecondLabel: UILabel!
    @IBOutlet weak var notificationStack: UIStackView!
    @IBOutlet weak var bandsStack: UIStackView!
    @IBOutlet weak var skillsStack: UIStackView!
    
    @IBAction func done(_ sender: Any) {
        if let ad = self.ad {
            provider.saveAd(ad)
        }
    }
    
    @IBAction func switchType(_ sender: Any) {
        typeDidChange()
    }
    
    @IBAction func notify(_ sender: Any) {
        notifyDidChange()
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.adDetailViewControllerDidCancel(self)
    }
    
    @IBAction func tapLocation(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
             
        if gestureRecognizer.state == .ended {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let locationViewController = storyboard.instantiateViewController(withIdentifier: "locationVC") as! LocationMapViewController
            locationViewController.delegate = self
            self.navigationController?.pushViewController(locationViewController, animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = MyAdsDetailProvider()
        self.provider.delegate = self
        self.provider.loadBands()
        self.provider.loadUser()
        
        self.bandsPicker.delegate = self
        self.bandsPicker.dataSource = self
        
        self.configView()
        
        if let id = self.id {
            do {
                try self.provider.loadAd(id)
            } catch {
                print(error)
            }
        } else {
            self.ad = MyAdsDetailViewModel()
            ad.setTypeFromView(Advertising.AdType.band)
            ad.setNotifyFromView(true)
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInsetsForKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInsetsForKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        	
    }
    
    @objc func adjustInsetsForKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let show = (notification.name == UIResponder.keyboardWillShowNotification) ? true : false
        if show == keyboardShow { return }
        
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.verticalScrollIndicatorInsets.bottom += adjustmentHeight
        
        keyboardShow = show
    }
    
    func configView () {
        skillsTextField.delegate = self
        genreTextField.delegate = self
        locationTextField.delegate = self
        
        skillsTextField.inputView = UIView()
        skillsTextField.inputAccessoryView = UIView()
        genreTextField.inputView = UIView()
        genreTextField.inputAccessoryView = UIView()
        locationTextField.inputView = UIView()
        locationTextField.inputAccessoryView = UIView()
        
        var selectionValues = [String]()
        for skill in skills {
            selectionValues.append(skill.rawValue)
        }
        skillsSelection = RSSelectionMenu(selectionStyle: .multiple, dataSource: selectionValues) { (cell, skill, indexPath) in
            cell.textLabel?.text = skill
        }
        skillsSelection!.setSelectedItems(items: selectedSkills) { [weak self] (item, index, isSelected, selectedItems) in
            self!.selectedSkills = selectedItems
            self!.skillsTextField.text = self!.selectedSkills.joined(separator: ", ")
            self!.ad?.setSkillsFromView(selectedItems)
        }
        
        selectionValues = [String]()
        for genre in genres {
            selectionValues.append(genre.rawValue)
        }
        genreSelection = RSSelectionMenu(selectionStyle: .multiple, dataSource: selectionValues) { (cell, genre, indexPath) in
            cell.textLabel?.text = genre
        }
        genreSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
            self!.selectedGenres = selectedItems
            self!.genreTextField.text = self!.selectedGenres.joined(separator: ", ")
            self!.ad?.setGenreFromView(selectedItems)
        }
        
    }
    
    func editConfig() {
        title = "Edit Advertising"
        addBarButton.isEnabled = true
        
        if let selectedSkills = ad?.getSkillForView() {
            self.selectedSkills = selectedSkills
            skillsTextField.text = selectedSkills.joined(separator: ", ")
            skillsSelection!.setSelectedItems(items: selectedSkills) { [weak self] (item, index, isSelected, selectedItems) in
                self!.selectedGenres = selectedItems
                self!.skillsTextField.text = self!.selectedSkills.joined(separator: ", ")
                self!.ad?.setSkillsFromView(selectedItems)
            }
        }
        
        if let selectedGenres = ad?.getGenreForView() {
            self.selectedGenres = selectedGenres
            genreTextField.text = selectedGenres.joined(separator: ", ")
            genreSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
                self!.selectedGenres = selectedItems
                self!.genreTextField.text = self!.selectedGenres.joined(separator: ", ")
                self!.ad?.setGenreFromView(selectedItems)
            }
        }
        
        locationTextField.text = ad?.getLocationForView()
        notificationSwitch.isOn = ad.notify
        ad.setNotifyFromView(!ad.notify)
        notifyDidChange()
        
        ad.setTypeFromView(ad.type == Advertising.AdType.band ? Advertising.AdType.musician : Advertising.AdType.band)
        typeDidChange()
        
        if ad.type == Advertising.AdType.band {
            var row = 0
            for (index, band) in self.bands.enumerated() {
                if band.id == ad.id_band! {
                    row = index
                }
            }
            bandsPicker.selectRow(row, inComponent: 0, animated: true)
        }
    }
    
    func notifyDidChange() {
        if ad.getNotifyForView() {
            ad.setNotifyFromView(false)
            notificationStack.isHidden = true
        } else {
            ad.setNotifyFromView(true)
            notificationStack.isHidden = false
        }
    }
    
    func typeDidChange() {
        if ad.getTypeForView() == Advertising.AdType.band {
            switchTypeFirstLabel.text = "Musician"
            switchTypeSecondLabel.text = "Band"
            bandsStack.isHidden = true
            ad.setTypeFromView(Advertising.AdType.musician)
        } else {
            ad.setTypeFromView(Advertising.AdType.band)
            switchTypeFirstLabel.text = "Band"
            switchTypeSecondLabel.text = "Musician"
            bandsStack.isHidden = false
        }
    }
}

extension MyAdsDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == skillsTextField {
            skillsSelection!.show(style: .popover(sourceView: skillsTextField, size: nil), from: self)
            textField.resignFirstResponder()
        }
        if textField == genreTextField {
            genreSelection!.show(style: .popover(sourceView: genreTextField, size: nil), from: self)
            textField.resignFirstResponder()
        }
    }
}

extension MyAdsDetailViewController: MyAdsDetailProviderProtocol {
    
    func providerDidFinishLoadingUser(provider of: MyAdsDetailProvider, user: User?) {
        if let user = user {
            self.user = user
        }
    }
    
    func providerDidFinishLoadingBands(provider of: MyAdsDetailProvider, bands: [Band]?) {
        if let bands = bands {
            self.bands = bands
            for band in bands {
                pickerData.append(band.name)
                bandsPicker.reloadAllComponents()
            }
            if self.id == nil {
                ad.setBandFromView(self.bands.first)
            }
        }
    }
    
    func providerDidFinishSavingAd(provider of: MyAdsDetailProvider, ad: Advertising) {
        if id == nil {
            delegate?.adDetailViewController(self, didFinishAdding: ad)
        } else {
            delegate?.adDetailViewController(self, didFinishEditing: ad)
        }
    }
    func providerDidFinishSavingAd(provider of: MyAdsDetailProvider, error: String) {
        print(error)
    }
    func providerDidLoadAd(provider of: MyAdsDetailProvider, ad: MyAdsDetailViewModel?) {
        if let ad = ad {
            self.ad = ad
            editConfig()
        } else if let error = provider.error {
            print(error.localizedDescription)
        }
    }
}

extension MyAdsDetailViewController: LocationMapViewControllerDelegate {
    func locationDidSet(_ controller: LocationMapViewController, location: Location?) {
        navigationController?.popViewController(animated: true)
        if let location = location {
            self.ad?.setLocationFromView(city: location.city, state: location.state, country: location.country, postalCode: location.postalCode, lat: location.lat, lng: location.lng)
            locationTextField.text = self.ad?.getLocationForView()
        }
    }
}

extension MyAdsDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let band = bands[row]
        ad.setBandFromView(band)
    }
    
}
