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
    private let validator = Validator()
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changeImageButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func done(_ sender: Any) {
        validator.validate(self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.profileDetailViewControllerDidCancel(self)
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
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.provider = ProfileProvider()
        self.provider.delegate = self
        
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
        nameTextField.loadLine()
        locationTextField.loadLine()
    }
    
    func configView () {
        nameTextField.delegate = self
        locationTextField.delegate = self
        
        locationTextField.inputView = UIView()
        locationTextField.inputAccessoryView = UIView()
        
        nameTextField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        
        let icon = UIImage.fontAwesomeIcon(name: .camera, style: .solid, textColor: .white, size: CGSize(width: 20, height: 20))
        changeImageButton.setImage(icon, for: .normal)
        
        validator.registerField(nameTextField, errorLabel: nameErrorLabel, rules: [RequiredRule()])
        validator.registerField(locationTextField, errorLabel: locationErrorLabel, rules: [RequiredRule()])
        
        hideError()
        
        nameTextField.defaultLayout()
        locationTextField.defaultLayout()
        
        changeImageButton.defaultLayout()
        changeImageButton.layer.cornerRadius = changeImageButton.frame.height / 2
        
        imageView.rounded()
    }
    
    func hideError() {
        nameErrorLabel.alpha = 0;
        locationErrorLabel.alpha = 0;
    }
    
    @objc func nameDidChange() {
        self.profile?.setNameFromView(nameTextField.text)
    }
    
    func editConfig() {
        title = "Edit Profile"
        addBarButton.isEnabled = true
        
        if let profile = self.profile, let image = profile.getPicturesForView() {
            imageView.loading()
            provider.loadImage(image: image, to:imageView)
        } else {
            let userIcon = UIImage.fontAwesomeIcon(name: .user, style: .solid, textColor: UIColor(rgb: 0x222222), size: CGSize(width: 100, height: 100))
            imageView.image = userIcon
            imageView.contentMode = .center
        }
        nameTextField.text = profile.getNameForView()

        locationTextField.text = profile?.getLocationForView()
        
    }
    
}

extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        self.view.removeSpinner()
    }
    func providerDidFinishSavingProfile(provider of: ProfileProvider, error: String) {
        print(error)
        self.view.removeSpinner()
    }
    func providerDidLoadProfile(provider of: ProfileProvider, profile: ProfileEditViewModel?) {
        if let profile = profile {
            self.profile = profile
            editConfig()
        } else if let error = provider.error {
            print(error.localizedDescription)
        }
        self.view.removeSpinner()
    }
    func providerDidLoadImage(provider of: ProfileProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            imageView.image = UIImage(data: data)
            imageView.loaded()
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

extension  ProfileEditViewController: ValidationDelegate {
    func validationSuccessful() {
        self.view.showSpinner(onView: self.view)
        provider.saveData(profile)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        hideError()
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.alpha = 1
        }
    }
}
