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

extension UITextView {
    
    func defaultLayout(reverse: Bool = false) {
        
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        self.textContainerInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        self.textContainer.lineFragmentPadding = 0
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.backgroundColor = nil
        self.font = UIFont(name: "Raleway", size: 16)
        self.textColor = reverse ? UIColor(rgb: 0xffffff) : UIColor(rgb: 0x222222)
        
        let view = UIView()
        view.backgroundColor = reverse ? UIColor(rgb: 0xffffff) : UIColor(rgb: 0x222222)
        self.addSubview(view)
        let constraints = [
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ]
        
        let fixedWidth = self.frame.size.width
        let newSize: CGSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        
        view.frame = CGRect(x: 0, y: newSize.height - 2, width: self.frame.width, height: 2)
        NSLayoutConstraint.activate(constraints)
        self.bringSubviewToFront(view)
        
    }
    
    func relayout() {
        let views = self.subviews
        for view in views {
            if view.frame.height == 2 {
                view.frame = CGRect(x: 0, y: self.frame.height - 2, width: self.frame.width, height: 2)
            }
        }
    }
}