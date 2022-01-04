//
//  UberBizDashedView.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 19/02/21.
//

import Foundation
import UIKit

class UberBizDashedView: UIView{
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews(){
        let dashedLayer = CAShapeLayer()
        dashedLayer.strokeColor = Color.PRIMARY_COLOR.cgColor
        dashedLayer.lineDashPattern = [5, 5]
        dashedLayer.frame = self.bounds
        dashedLayer.fillColor = nil
        dashedLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 6).cgPath
        self.layer.addSublayer(dashedLayer)
    }
}
