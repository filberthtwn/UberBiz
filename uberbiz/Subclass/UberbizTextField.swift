//
//  TextField.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import Foundation
import UIKit

class UberbizTextField: UITextField {
    
    var isRounded:Bool = false {
        didSet{
            if (isRounded){
                self.layer.cornerRadius = 6
            }
        }
    }
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
