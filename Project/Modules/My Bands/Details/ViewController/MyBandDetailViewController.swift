//
//  ViewController.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit

protocol MyBandDetailViewControllerDelegate: class {
    func bandDetailViewControllerDidCancel(_ controller: MyBandDetailViewController)
    func bandDetailViewController(_ controller: MyBandDetailViewController, didFinishAdding band: Band)
    func bandDetailViewController(_ controller: MyBandDetailViewController, didFinishEditing band: Band)
}

class MyBandDetailViewController: UIViewController {

    weak var delegate: MyBandDetailViewControllerDelegate?
    var band: MyBandDetailViewModel?
    var provider: MyBandDetailProvider! = nil
    var imagePicker: ImagePicker!
    private var keyboardShow = false
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        delegate?.bandDetailViewControllerDidCancel(self)
    }
    
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func done(_ sender: Any) {
        if let band = self.band {
            provider.saveBand(band)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.provider = MyBandDetailProvider()
        self.provider.delegate = self
        
        self.configView()
        
        if let band = self.band {
            self.editConfig(with: band)
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
        
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor(rgb: 0xCCCCCC).cgColor
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.contentInset = UIEdgeInsets(top: 8, left: 3, bottom: 8, right: 3)
        
        nameTextField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        genreTextField.addTarget(self, action: #selector(genreDidChange), for: .editingChanged)
        locationTextField.addTarget(self, action: #selector(locationDidChange), for: .editingChanged)
        
        imageView.layer.cornerRadius = 5;
        imageView.layer.masksToBounds = true;
        
    }
    
    @objc func nameDidChange() {
        self.band?.setNameFromView(nameTextField.text)
    }
    @objc func genreDidChange() {
        self.band?.setGenreFromView(genreTextField.text)
    }
    @objc func locationDidChange() {
        self.band?.setLocationFromView(locationTextField.text)
    }
    
    func editConfig(with band: MyBandDetailViewModel) {
        title = "Edit Item"
        addBarButton.isEnabled = true
        
        imageView.image = nil
        nameTextField.text = band.getNameForView()
        genreTextField.text = band.getGenreForView()
        locationTextField.text = band.getLocationForView()
        descriptionTextView.text = band.getDescriptionForView()
        
        textViewDidChange(descriptionTextView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let band = self.band, band.id != nil {
            imageView.load(url: URL(string: band.getPicturesForView()!)!)
        }
        nameTextField.becomeFirstResponder()
    }
}

extension MyBandDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    func providerDidFinishAddingBand(provider of: MyBandDetailProvider, band: Band) {
        delegate?.bandDetailViewController(self, didFinishAdding: band)
    }
    func providerDidFinishEditingBand(provider of: MyBandDetailProvider, band: Band) {
        delegate?.bandDetailViewController(self, didFinishEditing: band)
    }
}
