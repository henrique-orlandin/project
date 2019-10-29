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
}
