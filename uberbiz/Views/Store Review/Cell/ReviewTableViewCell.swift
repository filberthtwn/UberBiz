//
//  ReviewTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 20/02/21.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet var starIVs: [UIImageView]!
    
    @IBOutlet var ratingL: UILabel!
    @IBOutlet var customerNameL: UILabel!
    @IBOutlet var reviewDescL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
//        self.profileImageIV.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
