//
//  AddProductImageCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit

class AddProductImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var deleteView: UIView!
    
    var index = 0
    var delegate: AddProductDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.productImageView.layer.cornerRadius = 6
        self.deleteView.layer.cornerRadius = self.deleteView.frame.width/2
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.delegate?.deleteImage(index: index)
    }
    
}
