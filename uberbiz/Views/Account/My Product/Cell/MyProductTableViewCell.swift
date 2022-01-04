//
//  MyProductTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit

class MyProductTableViewCell: UITableViewCell {

    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var productPriceL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.productImageView.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
