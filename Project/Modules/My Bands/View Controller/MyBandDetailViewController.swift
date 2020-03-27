//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu
import Gallery
import SwiftValidator

protocol MyBandDetailViewControllerDelegate: class {
    func bandDetailViewControllerDidCancel(_ controller: MyBandDetailViewController)
    func bandDetailViewController(_ controller: MyBandDetailViewController, didFinishAdding band: Band)
    func bandDetailViewController(_ controller: MyBandDetailViewController, didFinishEditing band: Band)
}

class MyBandDetailViewController: UIViewController {
    
    weak var delegate: MyBandDetailViewControllerDelegate?
    public var id: String?
    private var band: MyBandDetailViewModel! = nil
    private var provider: MyBandDetailProvider! = nil
    private var imagePicker: ImagePicker!
    private var keyboardShow = false
    private var gallery: GalleryController! = nil
    private let validator = Validator()
    
    private let genres = Genre.allCases
    private var selectedGenres = [String]()
    private var genreSelection: RSSelectionMenu<String>?
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var changeImageButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var genreErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    @IBOutlet weak var descriptionErrorLabel: UILabel!
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func done(_ sender: Any) {
        
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = ""
        }
        
        validator.validate(self)
        
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = "Description"
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.bandDetailViewControllerDidCancel(self)
    }
    
    @IBAction func showGallery(_ sender: Any) {
        present(gallery, animated: true, completion: nil)
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
        self.provider = MyBandDetailProvider()
        self.provider.delegate = self
        
        gallery = GalleryController()
        gallery.delegate = self
        
        self.configView()
        
        if let id = self.id {
            do {
                try self.provider.loadBand(id)
                self.view.showSpinner(onView: self.view)
            } catch {
                print(error)
            }
        } else {
            self.band = MyBandDetailViewModel()
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
        genreTextField.delegate = self
        locationTextField.delegate = self
        descriptionTextView.delegate = self
        
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
            self!.band?.setGenreFromView(selectedItems)
        }
        
        nameTextField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        
        validator.registerField(nameTextField, errorLabel: nameErrorLabel, rules: [RequiredRule()])
        validator.registerField(genreTextField, errorLabel: genreErrorLabel, rules: [RequiredRule()])
        validator.registerField(locationTextField, errorLabel: locationErrorLabel, rules: [RequiredRule()])
        validator.registerField(descriptionTextView, errorLabel: descriptionErrorLabel, rules: [RequiredRule()])
        
        let bandIcon = UIImage.fontAwesomeIcon(name: .music, style: .solid, textColor: UIColor(rgb: 0x222222), size: CGSize(width: 100, height: 100))
        imageView.image = bandIcon
        imageView.contentMode = .center
        
        let icon = UIImage.fontAwesomeIcon(name: .camera, style: .solid, textColor: .white, size: CGSize(width: 20, height: 20))
        changeImageButton.setImage(icon, for: .normal)
        
        imageView.rounded()
        nameTextField.defaultLayout()
        genreTextField.defaultLayout()
        locationTextField.defaultLayout()
        descriptionTextView.defaultLayout()
        
        changeImageButton.defaultLayout()
        changeImageButton.layer.cornerRadius = changeImageButton.frame.height / 2
        
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = UIColor.lightGray
        
        hideError()
    }
    
    @objc func nameDidChange() {
        self.band?.setNameFromView(nameTextField.text)
    }
    
    func editConfig() {
        title = "Edit Band"
        addBarButton.isEnabled = true
        
        imageView.image = nil
        nameTextField.text = band?.getNameForView()
        if let selectedGenres = band?.getGenreForView() {
            self.selectedGenres = selectedGenres
            genreTextField.text = selectedGenres.joined(separator: ", ")
            genreSelection!.setSelectedItems(items: selectedGenres) { [weak self] (item, index, isSelected, selectedItems) in
                self!.selectedGenres = selectedItems
                self!.genreTextField.text = self!.selectedGenres.joined(separator: ", ")
                self!.band?.setGenreFromView(selectedItems)
            }
        }
        
        locationTextField.text = band?.getLocationForView()
        descriptionTextView.text = band?.getDescriptionForView()
        
        if !descriptionTextView.text.isEmpty {
            descriptionTextView.textColor = UIColor.black
        }
        
        textViewDidChange(descriptionTextView)
    }
    
    func hideError() {
        nameErrorLabel.alpha = 0
        genreErrorLabel.alpha = 0
        locationErrorLabel.alpha = 0
        descriptionErrorLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameTextField.loadLine()
        genreTextField.loadLine()
        locationTextField.loadLine()
        
        if self.id != nil, let band = self.band, let image = band.getPicturesForView() {
            imageView.image = nil
            imageView.loading()
            provider.loadImage(image: image, to:imageView)
        }
    }
}

extension MyBandDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == genreTextField {
            genreSelection!.show(style: .popover(sourceView: genreTextField, size: nil), from: self)
            textField.resignFirstResponder()
        }
    }
}

extension MyBandDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        //set description height to be dynamic
        let fixedWidth = textView.frame.size.width
        let newSize: CGSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: CGFloat(fmaxf(Float(newSize.width), Float(fixedWidth))), height: newSize.height)
        textView.frame = newFrame
        textView.relayout()
        self.band?.setDescriptionFromView(descriptionTextView.text)
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

extension MyBandDetailViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        imageView.contentMode = .scaleAspectFill
        self.imageView.image = image
        self.band?.setPicturesFromView(image)
    }
}

extension MyBandDetailViewController: MyBandDetailProviderProtocol {
    func providerDidFinishSavingBand(provider of: MyBandDetailProvider, band: Band) {
        if id == nil {
            delegate?.bandDetailViewController(self, didFinishAdding: band)
        } else {
            delegate?.bandDetailViewController(self, didFinishEditing: band)
        }
        self.view.removeSpinner()
    }
    func providerDidFinishSavingBand(provider of: MyBandDetailProvider, error: String) {
        print(error)
        self.view.removeSpinner()
    }
    func providerDidLoadBand(provider of: MyBandDetailProvider, band: MyBandDetailViewModel?) {
        if let band = band {
            self.band = band
            editConfig()
        } else if let error = provider.error {
            print(error.localizedDescription)
        }
        self.view.removeSpinner()
    }
    func providerDidLoadImage(provider of: MyBandDetailProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(data: data)
            imageView.loaded()
        }
    }
}

extension MyBandDetailViewController: LocationMapViewControllerDelegate {
    func locationDidSet(_ controller: LocationMapViewController, location: Location?) {
        navigationController?.popViewController(animated: true)
        if let location = location {
            self.band?.setLocationFromView(city: location.city, state: location.state, country: location.country, postalCode: location.postalCode, lat: location.lat, lng: location.lng)
            locationTextField.text = self.band?.getLocationForView()
        }
    }
}

extension MyBandDetailViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        
    }
}

extension MyBandDetailViewController: ValidationDelegate {
    func validationSuccessful() {
        self.view.showSpinner(onView: self.view)
        provider.saveBand(band)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        hideError()
        for (_, error) in errors {
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.alpha = 1
        }
    }
}
