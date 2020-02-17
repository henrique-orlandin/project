//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import RSSelectionMenu

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
    
    private let genres = Genre.allCases
    private var selectedGenres = [String]()
    private var genreSelection: RSSelectionMenu<String>?
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func done(_ sender: Any) {
        if let band = self.band {
            provider.saveBand(band)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.bandDetailViewControllerDidCancel(self)
    }
    
    @IBAction func tapLocation(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
             
        if gestureRecognizer.state == .ended { 
            let locationViewController = storyboard?.instantiateViewController(withIdentifier: "locationVC") as! LocationMapViewController
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
        
        self.configView()
        
        if let id = self.id {
            do {
                try self.provider.loadBand(id)
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
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor(rgb: 0xCCCCCC).cgColor
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.contentInset = UIEdgeInsets(top: 8, left: 3, bottom: 8, right: 3)
        
        nameTextField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        
        imageView.layer.cornerRadius = 5;
        imageView.layer.masksToBounds = true;
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
        }
        
        locationTextField.text = band?.getLocationForView()
        descriptionTextView.text = band?.getDescriptionForView()
        
        textViewDidChange(descriptionTextView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let band = self.band, let image = band.getPicturesForView() {
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
        
        self.band?.setDescriptionFromView(descriptionTextView.text)
    }
}

extension MyBandDetailViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
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
    }
    func providerDidFinishSavingBand(provider of: MyBandDetailProvider, error: String) {
        print(error)
    }
    func providerDidLoadBand(provider of: MyBandDetailProvider, band: MyBandDetailViewModel?) {
        if let band = band {
            self.band = band
            editConfig()
        } else if let error = provider.error {
            print(error.localizedDescription)
        }
    }
    func providerDidLoadImage(provider of: MyBandDetailProvider, imageView: UIImageView, data: Data?) {
        if let data = data {
            imageView.image = UIImage(data: data)
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
