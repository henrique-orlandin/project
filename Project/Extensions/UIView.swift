/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

extension UIView {
    
    func smoothRoundCorners(to radius: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: radius
        ).cgPath
        
        layer.mask = maskLayer
    }
    
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }
    
    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.tag = 1001
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        spinnerView.alpha = 0
        let panelWidth = CGFloat(100.0)
        let panelHeight = CGFloat(100.0)
        let panelX = (self.frame.width / 2) - 50
        let panelY = (self.frame.height / 2) - 135
        let panel = UIView(frame: CGRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight))
        panel.backgroundColor = UIColor.white
        panel.layer.cornerRadius = 10
        panel.layer.masksToBounds = true
        let spinnerLoader = SpinnerView(frame: CGRect(x: CGFloat(25.0), y: CGFloat(15.0), width: CGFloat(50.0), height: CGFloat(50.0)))
        let label = UILabel(frame: CGRect(x: 0, y: 70, width: 100, height: 25))
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.text = "Loading"
        label.textColor = UIColor(rgb: 0x2222222)
        label.textAlignment = .center
        
        DispatchQueue.main.async {
            panel.addSubview(spinnerLoader)
            panel.addSubview(label)
            spinnerView.addSubview(panel)
            onView.addSubview(spinnerView)
            spinnerView.fadeIn()
        }
    }
    
    func removeSpinner() {
        let subviews = self.subviews
        for subview in subviews {
            if let spinnerView = subview.viewWithTag(1001) {
                spinnerView.fadeOut()
            }
        }
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.0
        }
    }
    
    func collectionViewCellLayout() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 10
    }
    
}
