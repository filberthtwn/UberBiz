//
//  HomeCategoryCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit

class SubCategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet var subCategoryImageView: UIImageView!
    @IBOutlet var categoryNameL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.layoutIfNeeded()
        self.subCategoryImageView.layer.cornerRadius = self.subCategoryImageView.frame.width/2.0
    }
}
