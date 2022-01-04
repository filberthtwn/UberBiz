//
//  MessengerTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit

class MessengerTableViewCell: UITableViewCell {

    @IBOutlet var messengerImageView: UIImageView!
    @IBOutlet var nameL: UILabel!
    @IBOutlet var messageL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messengerImageView.layer.cornerRadius = self.messengerImageView.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
