//
//  UberBizRadioButtonView.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/03/21.
//

import UIKit

class UberBizRadioButtonView: UIView {

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews(){
        let width = self.frame.width * 0.35
        let height = self.frame.height * 0.35
        let innerView = UIView(frame: CGRect(x: (self.frame.width - width)/2, y: (self.frame.height - height)/2, width: width, height: height))
        innerView.backgroundColor = .white
        innerView.layer.cornerRadius = innerView.frame.height/2
        
        self.addSubview(innerView)
    }

}
