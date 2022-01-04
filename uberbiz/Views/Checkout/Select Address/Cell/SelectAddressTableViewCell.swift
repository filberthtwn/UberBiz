//
//  SelectAddressTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 11/01/21.
//

import UIKit

class SelectAddressTableViewCell: UITableViewCell {

    var delegate: SelectAddressProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func cellAction(_ sender: Any) {
        self.delegate?.didAddressTapped()
    }
    
    @IBAction func editAction(_ sender: Any) {
        self.delegate?.didEditTapped()
    }
    
}
