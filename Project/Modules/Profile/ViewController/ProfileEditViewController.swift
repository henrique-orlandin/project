//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

protocol ProfileEditViewControllerDelegate: class {
    func profileDetailViewControllerDidCancel(_ controller: ProfileEditViewController)
    func profileDetailViewController(_ controller: ProfileEditViewController, didFinishEditing profile: User)
}

class ProfileEditViewController: UIViewController {

    weak var delegate: ProfileEditViewControllerDelegate?
    private var profile: ProfileEditViewModel! = nil
    private var provider: ProfileProvider! = nil
    private var imagePicker: ImagePicker!
    private var keyboardShow = false
    
    private let skills = Skills.allCases
    private var selectedSkills = [String]()
    private var skillsSelection: RSSelectionMenu<String>?
    
    private let genres = Genre.allCases
    private var selectedGenres = [String]()
    private var genresSelection: RSSelectionMenu<String>?
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var isMusicianSwitch: UISwitch!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var genresTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var musicianContainer: UIStackView!
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func done(_ sender: Any) {
        if let profile = self.profile {
            provider.saveData(profile)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.profileDetailViewControllerDidCancel(self)
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
    
    @IBAction func tapLocation(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
             
        if gestureRecognizer.state == .ended {
            let storyboard = UIStoryboard.init(name: "MyBands", bundle: nil)
            let locationViewController = storyboard.instantiateViewController(withIdentifier: "locationVC") as! LocationMapViewController
            locationViewController.delegate = self
            self.navigationController?.pushViewController(locationViewController, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.provider = ProfileProvider()
        self.provider.delegate = self
        
        musicianContainer.isHidden = true
        
        self.configView()

        do {
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
    
    func configView () {
        nameTextField.delegate = self
        skillsTextField.delegate = self
        genresTextField.delegate = self
        locationTextField.delegate = self
        descriptionTextView.delegate = self
        
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
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor(rgb: 0xCCCCCC).cgColor
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.contentInset = UIEdgeInsets(top: 8, left: 3, bottom: 8, right: 3)
        
        nameTextField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        
        imageView.layer.cornerRadius = 5;
        imageView.layer.masksToBounds = true;
    }
    
    @objc func nameDidChange() {
        self.profile?.setNameFromView(nameTextField.text)
    }
    
    func editConfig() {
        title = "Edit Band"
        addBarButton.isEnabled = true
        
        if let profile = self.profile, let image = profile.getPicturesForView() {
            provider.loadImage(image: image, to:imageView)
        }
        nameTextField.text = profile.getNameForView()
        
        if let selectedSkills = profile?.getSkillForView() {
            self.selectedSkills = selectedSkills
            skillsTextField.text = selectedSkills.joined(separator: ", ")
        }
        if let selectedGenres = profile?.getGenreForView() {
            self.selectedGenres = selectedGenres
            genresTextField.text = selectedGenres.joined(separator: ", ")
        }
        
        locationTextField.text = profile?.getLocationForView()
        descriptionTextView.text = profile?.getDescriptionForView()
        
        textViewDidChange(descriptionTextView)
        
        isMusicianSwitch.isOn = profile.getIsMusicianForView()
        if isMusicianSwitch.isOn {
            musicianContainer.isHidden = false
        } else {
            musicianContainer.isHidden = true
        }
    }
    
}

extension ProfileEditViewController: UITextFieldDelegate {
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

extension ProfileEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        //set description height to be dynamic
        let fixedWidth = textView.frame.size.width
        let newSize: CGSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: CGFloat(fmaxf(Float(newSize.width), Float(fixedWidth))), height: newSize.height)
        textView.frame = newFrame
        
        self.profile?.setDescriptionFromView(descriptionTextView.text)
    }
}

extension ProfileEditViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.imageView.image = image
        self.profile?.setPicturesFromView(image)
    }
}

extension ProfileEditViewController: ProfileProviderProtocol {
    func providerDidFinishSavingProfile(provider of: ProfileProvider, profile: User) {
        delegate?.profileDetailViewController(self, didFinishEditing: profile)
    }
    func providerDidFinishSavingProfile(provider of: ProfileProvider, error: String) {
        print(error)
    }
    func providerDidLoadProfile(provider of: ProfileProvider, profile: ProfileEditViewModel?) {
        if let profile = profile {
            self.profile = profile
            editConfig()
        } else if let error = provider.error {
            print(error.localizedDescription)
        }
    }
    func providerDidLoadImage(provider of: ProfileProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            imageView.image = UIImage(data: data)
        }
    }
}

extension ProfileEditViewController: LocationMapViewControllerDelegate {
    func locationDidSet(_ controller: LocationMapViewController, location: Location?) {
        navigationController?.popViewController(animated: true)
        if let location = location {
            self.profile?.setLocationFromView(city: location.city, state: location.state, country: location.country, postalCode: location.postalCode, lat: location.lat, lng: location.lng)
            locationTextField.text = self.profile?.getLocationForView()
        }
    }
}
