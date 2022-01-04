//
//  ShimmerListingCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import UIKit

class ShimmerListingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var shimmerContainer: UberBizShimmerView!
    @IBOutlet var shimmerContent: UIView!
    @IBOutlet var containerViewTop: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shimmerContainer.contentView = shimmerContent
    }
    
    override func layoutSubviews() {
        self.layoutIfNeeded()
    }

}
