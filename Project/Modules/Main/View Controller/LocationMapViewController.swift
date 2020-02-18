//
//  MyBandDetailMapViewController.swift
//  Jam
//
//  Created by Henri on 2019-12-21.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import UIKit
import GoogleMaps

protocol LocationMapViewControllerDelegate: class {
    func locationDidSet(_ controller: LocationMapViewController, location: Location?)
}

class LocationMapViewController: UIViewController {
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var locationLabel: UITextView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabelHeightConstraint: NSLayoutConstraint!
    
    private let locationManager = CLLocationManager()
    private var location: Location?
    weak var delegate: LocationMapViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
    }
    
    @IBAction func done(_ sender: Any) {
        delegate?.locationDidSet(self, location: self.location)
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            self.locationLabel.text = lines.joined(separator: "\n")
            self.adjustLabelHeight()
            self.location = Location(city: address.locality, state: address.administrativeArea, country: address.country, postalCode: address.postalCode, lat: address.coordinate.latitude, lng: address.coordinate.longitude)
        }
    }
    
    private func adjustLabelHeight() {
        let fixedWidth = self.locationLabel.frame.size.width
        let newSize: CGSize = self.locationLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        locationLabelHeightConstraint.constant = newSize.height
    }
    
}

extension LocationMapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }

        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
}

extension LocationMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
}
