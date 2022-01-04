//
//  AllCompanyTargetCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/02/21.
//

import UIKit

class AllCompanyTargetCollectionViewCell: UICollectionViewCell {

    @IBOutlet var containerV: UIView!
    @IBOutlet var selectContainerV: UIView!
    
    var delegate:CompanyTargetProtocol?
    var isSelect:Bool = false{
        didSet{
            self.updateSelection()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.containerV.layer.cornerRadius = 6
        self.containerV.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.15).cgColor
        self.containerV.layer.shadowOpacity = 1
        self.containerV.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.containerV.layer.shadowRadius = 4
        self.containerV.layer.masksToBounds = false
        
        self.selectContainerV.backgroundColor = .white
        self.selectContainerV.layer.borderWidth = 1
        self.selectContainerV.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.15).cgColor
        self.selectContainerV.layer.cornerRadius = 6
    }
    
    private func updateSelection(){
        if self.isSelect{
            self.selectContainerV.backgroundColor = Color.PRIMARY_COLOR
        }else{
            self.selectContainerV.backgroundColor = .white
        }
    }
    
    @IBAction func selectAction(_ sender: Any) {
        self.isSelect = !self.isSelect
        self.delegate?.didSelectAll()
    }
}
