//
//  ShimmerCategoryTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 31/01/21.
//

import UIKit
import Shimmer

class ShimmerCategoryTableViewCell: UITableViewCell {

    @IBOutlet var imageV: UIView!
    @IBOutlet var shimmerContainerV: UberBizShimmerView!
    @IBOutlet var shimmerContentV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.shimmerContainerV.contentView = shimmerContentV
        self.imageV.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
