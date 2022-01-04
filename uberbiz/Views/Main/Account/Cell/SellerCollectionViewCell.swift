//
//  SellerCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit

protocol SellerProtocol {
    func didBuyeOrderTapped()
    func didEditStoreTapped()
    func didMyProductTapped()
    func didWithdrawTapped()
    func didAddProductTapped()
    func didSellerLogoutTapped()
    func didSignUpSellerTapped()
}

class SellerCollectionViewCell: UICollectionViewCell {

    @IBOutlet var storeImageView: UIImageView!
    @IBOutlet var storeNameL: UILabel!
    @IBOutlet var balanceL: UILabel!
    
    @IBOutlet var editStoreV: UIView!
    @IBOutlet var storeNameEmptyV: UIView!
    @IBOutlet var editStoreEmptyV: UIView!
    
    @IBOutlet var emptyV: UIView!
    @IBOutlet var sellerMenuSV: UIStackView!
    
    @IBOutlet var balanceRpContainerV: UIView!
    @IBOutlet var loginV: UIView!
    
    var delegate: SellerProtocol?
    var user: User? = nil {
        didSet{
            self.setupDefaultValue()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.storeImageView.layer.cornerRadius = self.storeImageView.frame.width/2
        
        self.balanceRpContainerV.layer.cornerRadius = 4
        self.balanceRpContainerV.layer.borderWidth = 1
        self.balanceRpContainerV.layer.borderColor = UIColor(red: 255/255, green: 107/255, blue: 0/255, alpha: 1).cgColor
    }
    
    private func setupDefaultValue(){
        if let user = self.user{
            print(user)
            if user.storeName != nil{
                if let imageUrlString = user.storeImageUrl{
                    if let imageUrl = URL(string: Network.ASSET_URL + imageUrlString){
                        self.storeImageView.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                    }
                }
                self.storeNameL.text = user.storeName
                self.balanceL.text = "Rp." + CurrencyHelper.shared.formatCurrency(price: String(user.storeBalance ?? 0))!
            }else{
                self.storeNameL.isHidden = true
                self.editStoreV.isHidden = true
                
                self.emptyV.isHidden = false
                self.storeNameEmptyV.layer.cornerRadius = 10
                self.editStoreEmptyV.layer.cornerRadius = 10
                
                self.sellerMenuSV.isHidden = true
                self.loginV.isHidden = false
            }
        }
    }
    
    @IBAction func withdrawAction(_ sender: Any) {
        self.delegate?.didWithdrawTapped()
    }
    
    @IBAction func buyerOrderAction(_ sender: Any) {
        self.delegate?.didBuyeOrderTapped()
    }
    
    @IBAction func editStoreAction(_ sender: Any) {
        self.delegate?.didEditStoreTapped()
    }
    
    @IBAction func myProductAction(_ sender: Any) {
        self.delegate?.didMyProductTapped()
    }
    
    @IBAction func addProductAction(_ sender: Any) {
        self.delegate?.didAddProductTapped()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        self.delegate?.didSellerLogoutTapped()
    }
    
    @IBAction func signupAction(_ sender: Any) {
        self.delegate?.didSignUpSellerTapped()
    }
}
