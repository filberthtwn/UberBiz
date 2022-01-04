//
//  ImageCellTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 23/02/21.
//

import UIKit

class ChatImageTableViewCell: UITableViewCell {

    @IBOutlet var chatImageIV: UIImageView!
    @IBOutlet var chatImageIVLeadingC: NSLayoutConstraint!
    @IBOutlet var chatImageIVTrailingC: NSLayoutConstraint!
    @IBOutlet var chatImageIVHeightC: NSLayoutConstraint!
    @IBOutlet var chatImageIVWidthC: NSLayoutConstraint!
    
    var index: Int = 0
    var delegate: ChatDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func imageSelectAction(_ sender: Any) {
        self.delegate?.didSelectImage(index: self.index)
    }
}
