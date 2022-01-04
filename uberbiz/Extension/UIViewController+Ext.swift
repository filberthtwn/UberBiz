//
//  UIViewController+Ext.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import Foundation
import UIKit

extension UIViewController{
    
//    convenience init(test: String) {
//           self.init(nibName: nil, bundle: nil)
//           print(test)
//       }
    
//    oveconvenience init() {
//       self.init(nibName: nil, bundle: nil)
//       print("ABC")
//    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
