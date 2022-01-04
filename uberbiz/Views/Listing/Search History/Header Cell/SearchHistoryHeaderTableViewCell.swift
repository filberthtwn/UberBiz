//
//  SearchHistoryHeaderTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/03/21.
//

import UIKit

class SearchHistoryHeaderTableViewCell: UITableViewCell {

    @IBOutlet var clearHistoryBtn: UIButton!
    var delegate: SearchHistoryDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clearAction(_ sender: Any) {
        self.delegate?.didClearHistory()
    }
}
