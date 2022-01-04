//
//  DefaultOrderTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 07/01/21.
//

import UIKit

class DefaultOrderTableViewCell: UITableViewCell {

    @IBOutlet var listingIV: UIImageView!
    @IBOutlet var listingNameL: UILabel!
    @IBOutlet var listingPriceL: UILabel!
    @IBOutlet var listingQuantityL: UILabel!
    
    @IBOutlet var confirmBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }

    private func setupViews(){
        self.confirmBtn.layer.cornerRadius = 6
    }
    
    @IBAction func confirmAction(_ sender: Any) {
//        self.delega
    }
    
}
