//
//  FileManager.swift
//  Project
//
//  Created by Henrique Orlandin on 2019-10-26.
//  Copyright © 2019 Henrique Orlandin. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
    func rounded() {
        self.layer.cornerRadius = self.frame.height / 2;
        self.layer.masksToBounds = true;
        self.layer.borderWidth = 3;
        self.layer.borderColor = UIColor(rgb: 0x222222).cgColor
    }
    
    func loading() {
        let width = self.frame.width * 50 / 100
        let height = self.frame.height * 50 / 100
        let x = self.frame.width * 25 / 100
        let y = self.frame.height * 25 / 100
        let spinner = SpinnerView(frame: CGRect(x: x, y: y, width: width, height: height))
        spinner.alpha = 0;
        self.addSubview(spinner)
        self.bringSubviewToFront(spinner)
        spinner.fadeIn()
    }
    
    func loaded() {
        let subviews = self.subviews
        for subview in subviews {
            if let spinnerView = subview as? SpinnerView {
                spinnerView.fadeOut()
            }
        }
    }
}
