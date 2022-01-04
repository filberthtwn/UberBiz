//
//  BuyerCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit

protocol BuyerProtocol {
    func didLoginTapped()
    func didMyOrderTapped()
    func didEditProfileTapped()
    func didCreateRequestTapped()
    func didLogoutTapped()
}

class BuyerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var usernameL: UILabel!
    @IBOutlet var emailL: UILabel!
    @IBOutlet var buyerImageView: UIImageView!
    
    @IBOutlet var buyerMenuSV: UIStackView!
    
    @IBOutlet var emptyV: UIView!
    @IBOutlet var usernameEmptyV: UIView!
    @IBOutlet var emailEmptyV: UIView!
    @IBOutlet var loginV: UIView!
    
    @IBOutlet var loginBtn: UberBizButton!
    
    var delegate:BuyerProtocol?
    var user: User? = nil {
        didSet{
            self.setupViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        if let user = self.user{
            if user.username != nil{
                self.usernameL.text = user.username
                self.emailL.text = user.buyerEmail
                
                self.emptyV.isHidden = true
                
                self.buyerMenuSV.isHidden = false
                self.loginV.isHidden = true
            }else{
                self.usernameL.isHidden = true
                self.emailL.isHidden = true
                
                self.emptyV.isHidden = false

                self.usernameEmptyV.layer.cornerRadius = 10
                self.emailEmptyV.layer.cornerRadius = 10

                self.buyerMenuSV.isHidden = true
                self.loginV.isHidden = false
                
                self.loginBtn.layer.cornerRadius = 6
            }
        }
        
//        self.buyerImageView.layer.borderWidth = 1
//        self.buyerImageView.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25).cgColor
        self.buyerImageView.layer.cornerRadius = self.buyerImageView.frame.height/2
    }
    
    @IBAction func myOrderAction(_ sender: Any) {
        self.delegate?.didMyOrderTapped()
    }
    
    @IBAction func editProfileAction(_ sender: Any) {
        self.delegate?.didEditProfileTapped()
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.delegate?.didLoginTapped()
    }
    
    @IBAction func createRequestAction(_ sender: Any) {
        self.delegate?.didCreateRequestTapped()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        self.delegate?.didLogoutTapped()
    }
    
}
