//
//  QuotatioTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 22/02/21.
//

import UIKit

class QuotationTableViewCell: UITableViewCell {

    @IBOutlet var productImageIV: UIImageView!
    
    @IBOutlet var titleL: UILabel!
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var productPriceL: UILabel!
    
    @IBOutlet var quotationLeadingC: NSLayoutConstraint!
    @IBOutlet var quotationTrailingC: NSLayoutConstraint!
    
    @IBOutlet var containerV: UIView!
    
    var delegate: ChatDelegate?
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.containerV.layer.cornerRadius = 10
        self.productImageIV.layer.cornerRadius = 6
    }
    
    @IBAction func selectProductAction(_ sender: Any) {
        self.delegate?.didSelectQuotation(index: self.index)
    }
    
}
