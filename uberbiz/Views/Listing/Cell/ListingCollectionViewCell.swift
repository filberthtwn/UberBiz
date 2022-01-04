//
//  NewListingCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/01/21.
//

import UIKit

class ListingCollectionViewCell: UICollectionViewCell {

    @IBOutlet var containerViewTop: NSLayoutConstraint!
    @IBOutlet var containerView: UIView!
    @IBOutlet var testView: UIView!
    @IBOutlet var contentStackView: UIStackView!
    
    @IBOutlet var productIV: UIImageView!
    
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var priceL: UILabel!
    @IBOutlet var cityNameL: UILabel!
    @IBOutlet var minimumOrderL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.testView.layer.cornerRadius = 8
        self.testView.layer.masksToBounds = true
        
        self.containerView.layer.cornerRadius = 8
        self.containerView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15)
        self.containerView.layer.shadowOpacity = 1
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.containerView.layer.shadowRadius = 8
        self.containerView.layer.masksToBounds = false
    }

}
