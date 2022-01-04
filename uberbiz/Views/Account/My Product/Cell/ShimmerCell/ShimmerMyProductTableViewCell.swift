//
//  ShimmerMyProductTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 31/01/21.
//

import UIKit
import Shimmer

class ShimmerMyProductTableViewCell: UITableViewCell {

    @IBOutlet var shimmerContainerV: UberBizShimmerView!
    @IBOutlet var shimmerContentV: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.shimmerContainerV.contentView = self.shimmerContentV
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
