//
//  CreateQuotationViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 11/02/21.
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa
import SwiftyJSON

protocol CreateQuotationProtocol{
    func didProductSelected(product: Product)
}

class CreateQuotationViewController: UIViewController {

    @IBOutlet var productContainerV: UIView!
    @IBOutlet var productContentV: UIView!
    @IBOutlet var radioBtnContainerV: UIView!
    @IBOutlet var radioBtnInnerV: UIView!
    
    @IBOutlet var productIV: UIImageView!
    
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var productPriceL: UILabel!
    
    @IBOutlet var quotationDescTF: UITextField!
    @IBOutlet var quotationPriceTF: UITextField!
    @IBOutlet var quotationQuantityTF: UITextField!
    @IBOutlet var quotationDeliveryNameTF: UITextField!
    @IBOutlet var quotationDeliveryFeeTF: UITextField!
    @IBOutlet var quotationDeliveryTimeTF: UITextField!
    
    @IBOutlet var selectProductBtn: UIButton!
    
    @IBOutlet var transportSV: UIStackView!
        
    var buyerQbUserId: UInt?
    var shippingAddressId:Int?
//    var shippingAddress: Address?
    var selectedProduct: Product?
    
    private var quotationResp: QuotationResp?
    private var isUsingTransport = false
    private var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.observeViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let product = self.selectedProduct{
            if product.images.count > 0{
                if let imageURL = URL(string: Network.ASSET_URL + product.images[0].imageUrl){
                    self.productIV.af.setImage(withURL: imageURL, placeholderImage: UIImage(named: "img_placeholder"))
                }
            }else{
                self.productIV.image = UIImage(named: "img_placeholder")
            }
            self.productNameL.text = product.itemName
            self.productPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: product.price)! + "/" + product.unit.unitName
            self.productContentV.isHidden = false
            self.selectProductBtn.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    private func setupViews(){
        self.title = "Create Quotation"
        
        self.productContainerV.layer.cornerRadius = 6
        self.productContainerV.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.15).cgColor
        self.productContainerV.layer.shadowOpacity = 1
        self.productContainerV.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.productContainerV.layer.shadowRadius = 3
        
        self.productIV.layer.cornerRadius = 6
        
        self.radioBtnContainerV.layer.cornerRadius = self.radioBtnContainerV.frame.height/2
        self.radioBtnContainerV.layer.borderWidth = 1
        self.radioBtnContainerV.layer.borderColor = Color.BORDER_COLOR
        
        self.radioBtnInnerV.layer.cornerRadius = self.radioBtnInnerV.frame.height/2
        
        self.selectProductBtn.layer.cornerRadius = 6
        
        self.radioBtnContainerV.backgroundColor = .white
    }
    
    private func observeViewModel(){
        QuotationVM.shared.quotationResp.bind { (quotationResp) in
            self.quotationResp = quotationResp
                
            self.disposeBag = DisposeBag()
            
            SVProgressHUD.showSuccess(withStatus: "Create quotation successful")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            
            for vc in self.navigationController!.viewControllers as Array {
                if vc.isKind(of: ChatViewController.self) {
                    self.navigationController!.popToViewController(vc, animated: true)
                    break
                }
            }
        }.disposed(by: disposeBag)
        
        QuotationVM.shared.errorMsg.bind{ (errMsg) in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func isValid()->Bool{
        if self.quotationDescTF.text == ""{
            return false
        }
        
        if self.quotationPriceTF.text == ""{
            return false
        }
        
        if self.quotationQuantityTF.text == ""{
            return false
        }
        
        if self.isUsingTransport{
            if self.quotationDeliveryNameTF.text == ""{
                return false
            }
            
            if self.quotationDeliveryFeeTF.text == ""{
                return false
            }
            
            if self.quotationDeliveryTimeTF.text == ""{
                return false
            }
        }
        
        return true
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if self.isValid(){
            if let selectedProduct = self.selectedProduct{
                
                SVProgressHUD.show()
                
                var quotation = Quotation()
                quotation.product = selectedProduct
                quotation.description = self.quotationDescTF.text!
                quotation.price = Int(self.quotationPriceTF.text!)!
                quotation.quantity = self.quotationQuantityTF.text!
                
                if self.isUsingTransport{
                    quotation.shippingName = self.quotationDeliveryNameTF.text!
                    quotation.shippingCost = Int(self.quotationDeliveryFeeTF.text!)!
                    quotation.shippingTimeEstimation = Int(self.quotationDeliveryTimeTF.text!)!
                }
                
                guard let shippingAddressId = self.shippingAddressId else {
                    SVProgressHUD.showError(withStatus: "Shipping Address Missing")
                    SVProgressHUD.dismiss()
                    
                    return
                }
                
                QuotationVM.shared.createQuotation(quotation: quotation, shippingAddressId: shippingAddressId)
            }else{
                SVProgressHUD.showError(withStatus: "Select product first")
                SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            }
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    @IBAction func transportAction(_ sender: Any) {
        self.isUsingTransport = !self.isUsingTransport
        if self.isUsingTransport{
            self.transportSV.isHidden = false
            self.radioBtnContainerV.backgroundColor = Color.PRIMARY_COLOR
        }else{  
            self.transportSV.isHidden = true
            self.radioBtnContainerV.backgroundColor = .white
        }
    }
    
    @IBAction func selectProductAction(_ sender: Any) {
        let myProductVC = MyProductViewController()
        myProductVC.createQuotationDelegate = self
        myProductVC.sourceVC = MyProductSource.QUOTATION
        self.navigationController?.pushViewController(myProductVC, animated: true)
    }
}

extension CreateQuotationViewController: CreateQuotationProtocol{
    func didProductSelected(product: Product) {
        self.selectedProduct = product
    }
}
