//
//  RequestTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 15/02/21.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet var requestIV: UIImageView!
    @IBOutlet var titleL: UILabel!
    
    @IBOutlet var containerV: UIView!
    @IBOutlet var requestTitleL: UILabel!
    
    @IBOutlet var requestTrailingC: NSLayoutConstraint!
    @IBOutlet var requestLeadingC: NSLayoutConstraint!
    
    var delegate: ChatDelegate?
    var index: Int?
    
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
    
    @IBAction func selectAction(_ sender: Any) {
        delegate?.didSelectRequestQuotation(index: index)
    }
}
