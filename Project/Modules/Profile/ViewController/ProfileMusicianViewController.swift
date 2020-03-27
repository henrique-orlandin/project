//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu
import SwiftValidator

class ProfileMusicianViewController: UIViewController {

    private var profile: ProfileMusicianViewModel! = nil
    private var provider: ProfileMusicianProvider! = nil
    private var keyboardShow = false
    private let validator = Validator()
    
    private let skills = Skills.allCases
    private var selectedSkills = [String]()
    private var skillsSelection: RSSelectionMenu<String>?
    
    private let genres = Genre.allCases
    private var selectedGenres = [String]()
    private var genresSelection: RSSelectionMenu<String>?
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var isMusicianSwitch: UISwitch!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var genresTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var musicianContainer: UIStackView!
    
    @IBOutlet weak var genreErrorLabel: UILabel!
    @IBOutlet weak var skillsErrorLabel: UILabel!
    @IBOutlet weak var descriptionErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    
    @IBAction func done(_ sender: Any) {
        validator.validate(self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
    
    @IBAction func showMusicianFields(_ sender: Any) {
        if let switchView = sender as? UISwitch {
            profile.setMusicianFromView(switchView.isOn)
            if switchView.isOn {
                musicianContainer.isHidden = false
            } else {
                musicianContainer.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.provider = ProfileMusicianProvider()
        self.provider.delegate = self
        
        musicianContainer.isHidden = true
        
        self.configView()

        do {
            self.view.showSpinner(onView: self.view)
            try self.provider.loadProfile()
        } catch {
            print(error)
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
    
    override func viewDidAppear(_ animated: Bool) {
        skillsTextField.loadLine()
        genresTextField.loadLine()
        locationTextField.loadLine()
    }
    
    func configView () {
        skillsTextField.delegate = self
        genresTextField.delegate = self
        descriptionTextView.delegate = self
        locationTextField.delegate = self
        
        skillsTextField.inputView = UIView()
        skillsTextField.inputAccessoryView = UIView()
        genresTextField.inputView = UIView()
        genresTextField.inputAccessoryView = UIView()
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
            self!.profile?.setSkillFromView(selectedItems)
        }
        
        selectionValues = [String]()
        for genre in genres {
            selectionValues.append(genre.rawValue)
        }
        genresSelection = RSSelectionMenu(selectionStyle: .multiple, dataSource: selectionValues) { (cell, genre, indexPath) in
            cell.textLabel?.text = genre
        }
        genresSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
            self!.selectedGenres = selectedItems
            self!.genresTextField.text = self!.selectedGenres.joined(separator: ", ")
            self!.profile?.setGenreFromView(selectedItems)
        }
        
        validator.registerField(genresTextField, errorLabel: genreErrorLabel, rules: [RequiredRule()])
        validator.registerField(skillsTextField, errorLabel: skillsErrorLabel, rules: [RequiredRule()])
        validator.registerField(descriptionTextView, errorLabel: descriptionErrorLabel, rules: [RequiredRule()])
        
        skillsTextField.defaultLayout()
        genresTextField.defaultLayout()
        descriptionTextView.defaultLayout()
        locationTextField.defaultLayout()
        
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.lightGray
        
        hideError()
    }
    
    func hideError() {
        genreErrorLabel.alpha = 0;
        skillsErrorLabel.alpha = 0;
        locationErrorLabel.alpha = 0
        descriptionErrorLabel.alpha = 0;
    }
    
    func editConfig() {
        title = "Musician Profile"
        addBarButton.isEnabled = true
        
        if let selectedSkills = profile?.getSkillForView() {
            self.selectedSkills = selectedSkills
            skillsTextField.text = selectedSkills.joined(separator: ", ")
            skillsSelection!.setSelectedItems(items: selectedSkills) { [weak self] (item, index, isSelected, selectedItems) in
                self!.selectedSkills = selectedItems
                self!.skillsTextField.text = self!.selectedSkills.joined(separator: ", ")
                self!.profile?.setSkillFromView(selectedItems)
            }
        }

        if let selectedGenres = profile?.getGenreForView() {
            self.selectedGenres = selectedGenres
            genresTextField.text = selectedGenres.joined(separator: ", ")
            genresSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
                self!.selectedGenres = selectedItems
                self!.genresTextField.text = self!.selectedGenres.joined(separator: ", ")
                self!.profile?.setGenreFromView(selectedItems)
            }
        }
        
        locationTextField.text = profile?.getLocationForView()
        
        let description = profile?.getDescriptionForView()
        
        textViewDidChange(descriptionTextView)
        if let description = description, !description.isEmpty {
            descriptionTextView.text = description
            descriptionTextView.textColor = UIColor.black
        }
        
        isMusicianSwitch.isOn = profile.getIsMusicianForView()
        if isMusicianSwitch.isOn {
            musicianContainer.isHidden = false
        } else {
            musicianContainer.isHidden = true
        }
    }
    
}

extension ProfileMusicianViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == skillsTextField {
            skillsSelection!.show(style: .popover(sourceView: skillsTextField, size: nil), from: self)
            textField.resignFirstResponder()
        }
        if textField == genresTextField {
            genresSelection!.show(style: .popover(sourceView: genresTextField, size: nil), from: self)
            textField.resignFirstResponder()
        }
    }
}

extension ProfileMusicianViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        //set description height to be dynamic
        let fixedWidth = textView.frame.size.width
        let newSize: CGSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: CGFloat(fmaxf(Float(newSize.width), Float(fixedWidth))), height: newSize.height)
        textView.frame = newFrame
        textView.relayout()
        self.profile?.setDescriptionFromView(descriptionTextView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension ProfileMusicianViewController: ProfileMusicianProviderProtocol {
    func providerDidFinishSavingProfile(provider of: ProfileMusicianProvider) {
        navigationController?.popViewController(animated: true)
        self.view.removeSpinner()
    }
    func providerDidFinishSavingProfile(provider of: ProfileMusicianProvider, error: String) {
        print(error)
        self.view.removeSpinner()
    }
    func providerDidLoadProfile(provider of: ProfileMusicianProvider, profile: ProfileMusicianViewModel?) {
        if let profile = profile {
            self.profile = profile
            editConfig()
        } else if let error = provider.error {
            print(error.localizedDescription)
        }
        self.view.removeSpinner()
    }
}

extension  ProfileMusicianViewController: ValidationDelegate {
    func validationSuccessful() {
        provider.saveData(profile)
        self.view.showSpinner(onView: self.view)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        hideError()
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.alpha = 1
        }
    }
}

extension ProfileMusicianViewController: LocationMapViewControllerDelegate {
    func locationDidSet(_ controller: LocationMapViewController, location: Location?) {
        navigationController?.popViewController(animated: true)
        if let location = location { 
            self.profile?.setLocationFromView(city: location.city, state: location.state, country: location.country, postalCode: location.postalCode, lat: location.lat, lng: location.lng)
            locationTextField.text = self.profile?.getLocationForView()
        }
    }
}
