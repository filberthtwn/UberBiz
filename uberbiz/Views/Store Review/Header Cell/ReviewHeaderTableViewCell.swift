//
//  ReviewHeaderTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 20/02/21.
//

import UIKit

class ReviewHeaderTableViewCell: UITableViewCell {

    @IBOutlet var storeImageIV: UIImageView!
    @IBOutlet var verifiedIV: UIImageView!
    
    @IBOutlet var storeNameL: UILabel!
    @IBOutlet var storeRatingL: UILabel!
    @IBOutlet var storeDescL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.storeImageIV.layer.cornerRadius = self.storeImageIV.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
