//
//  UberBizButton.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit

class UberBizButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupViews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews(){
        self.layer.cornerRadius = 6
    }
    
    func mute(){
        self.isEnabled = false
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = UIColor.init(red: 218/255, green: 218/255, blue: 218/255, alpha: 1)
    }
    
    func unmutePrimary(){
        self.isEnabled = true
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = Color.PRIMARY_COLOR
    }
}
