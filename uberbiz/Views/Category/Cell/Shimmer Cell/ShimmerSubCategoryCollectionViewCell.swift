//
//  ShimmerSubCategoryCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 31/01/21.
//

import UIKit
import Shimmer

class ShimmerSubCategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageV: UIView!
    @IBOutlet var shimmerContainerV: UberBizShimmerView!
    @IBOutlet var shimmerContentV: UIView!
       
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.shimmerContainerV.contentView = shimmerContentV
    }
    
    override func layoutSubviews() {
        self.layoutIfNeeded()
        self.imageV.layer.cornerRadius = self.imageV.frame.width/2
    }

}
