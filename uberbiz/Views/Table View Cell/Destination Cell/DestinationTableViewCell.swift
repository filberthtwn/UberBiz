//
//  DestinationTableViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/02/21.
//

import UIKit

class DestinationTableViewCell: UITableViewCell {

    @IBOutlet var textL: UILabel!
    @IBOutlet var radioBtnV: UIView!
    @IBOutlet var chevronDownIV: UIImageView!
    @IBOutlet var lineV: UIView!
    
    var index:Int = 0
    var section:Int = 0
    var delegate: DestinationListProtocol?
    
    var isSelect:Bool = false {
        didSet{
            if (isSelect){
                self.radioBtnV.backgroundColor = Color.PRIMARY_COLOR
            }else{
                self.radioBtnV.backgroundColor = .white
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.radioBtnV.layer.cornerRadius = self.radioBtnV.frame.height/2
        self.radioBtnV.layer.borderWidth = 1
        self.radioBtnV.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25).cgColor
    }
    
    override func layoutSubviews() {
        self.setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func selectAction(_ sender: Any) {
        if self.radioBtnV.backgroundColor == UIColor.white{
            self.radioBtnV.backgroundColor = Color.PRIMARY_COLOR
        }else{
            self.radioBtnV.backgroundColor = .white
        }
        self.delegate?.didRadioButtonTapped(section: self.section, index: self.index)
    }
    
}
