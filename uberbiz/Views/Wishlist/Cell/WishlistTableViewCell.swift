//
//  WishlistTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/01/21.
//

import UIKit

class WishlistTableViewCell: UITableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var deleteView: UIView!
    
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var productPriceL: UILabel!
    @IBOutlet var productCityL: UILabel!
    @IBOutlet var listingImageView: UIImageView!
    
    var wishlistProtocol: WishlistProtocol?
    var wishlist: Wishlist?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupViews()
    }
    
    private func setupViews(){
        
        self.containerView.layer.cornerRadius = 10
        self.containerView.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.15).cgColor
        self.containerView.layer.shadowOpacity = 1
        self.containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.containerView.layer.shadowRadius = 3
        self.containerView.layer.masksToBounds = false

        self.deleteView.layer.cornerRadius = 6
        self.deleteView.layer.borderWidth = 1
        self.deleteView.layer.borderColor = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1).cgColor
        
        self.listingImageView.layer.cornerRadius = 6
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.wishlistProtocol?.didWishlistDeleted(wishlist: self.wishlist!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
