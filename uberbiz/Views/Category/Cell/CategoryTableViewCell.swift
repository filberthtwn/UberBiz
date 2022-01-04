//
//  CategoryTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet var categoryV: UIView!
    @IBOutlet var categoryImageView: UIImageView!
    @IBOutlet var categoryNameL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.categoryImageView.layer.cornerRadius = 20
        
        self.categoryV.layer.cornerRadius = 20
        self.categoryV.layer.borderWidth = 5
        self.categoryV.layer.borderColor = UIColor(red: 180/255, green: 214/255, blue: 255/255, alpha: 1).cgColor
    }
    
    func selectItem(){
        self.categoryV.layer.borderColor = UIColor(red: 180/255, green: 214/255, blue: 255/255, alpha: 1).cgColor
    }
    
    func deselectItem(){
        self.categoryV.layer.borderColor = UIColor.white.cgColor
    }
    
    
}
