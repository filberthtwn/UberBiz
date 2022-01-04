//
//  RoundedImageView.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 27/11/21.
//

import Foundation
import UIKit

class RoundedImageView: UIImageView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup(){
        layer.cornerRadius = 10
    }
}
