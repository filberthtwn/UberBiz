//
//  ChatTextTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/02/21.
//

import UIKit

class ChatTextTableViewCell: UITableViewCell {

    @IBOutlet var containerV: UIView!
    @IBOutlet var messageL: UILabel!
    
    @IBOutlet var containerVLeadingC: NSLayoutConstraint!
    @IBOutlet var containerVTrailingC: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.containerV.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
