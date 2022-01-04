//
//  UberBizShimmerView.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import Foundation
import Shimmer

class UberBizShimmerView: FBShimmeringView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews(){
        self.shimmeringSpeed = 1000
        self.isShimmering = true
    }
}
