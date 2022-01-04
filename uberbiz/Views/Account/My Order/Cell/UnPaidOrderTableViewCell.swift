//
//  UnPaidOrderTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 07/01/21.
//

import UIKit

class UnPaidOrderTableViewCell: UITableViewCell {

    @IBOutlet var listingIV: UIImageView!
    @IBOutlet var listingNameL: UILabel!
    @IBOutlet var listingPriceL: UILabel!
    @IBOutlet var listingQuantityL: UILabel!
    @IBOutlet var listingTotalL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
