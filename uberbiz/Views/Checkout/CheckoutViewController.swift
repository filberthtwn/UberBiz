//
//  CheckoutViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 11/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

protocol CheckoutDelegate {
    func didPaymentMethodSelected()
}

class CheckoutViewController: UIViewController {

    @IBOutlet var insuranceChecklistView: UberBizRadioButtonView!
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var productPriceL: UILabel!
    @IBOutlet var productQuantity: UILabel!
    
    @IBOutlet var addressTitleL: UILabel!
    @IBOutlet var fullAddressL: UILabel!
    @IBOutlet var districtCityProvinceL: UILabel!
    @IBOutlet var phoneNumberL: UILabel!
    @IBOutlet var postalCodeL: UILabel!
    
    @IBOutlet var shippingNameTimeEstimationL: UILabel!
    @IBOutlet var shippingFeeL: UILabel!
    
    @IBOutlet var escrowFeeL: UILabel!
    @IBOutlet var insuranceFeeL: UILabel!
    @IBOutlet var totalPriceL: UILabel!
//    @IBOutlet var noTransportL: UILabel!
    
    @IBOutlet var shippingNameTF: UITextField!
    @IBOutlet var shippingFeeTF: UITextField!
    @IBOutlet var shippingTimeTF: UITextField!
    
    @IBOutlet var chooseTransportBtn: UIButton!
    @IBOutlet var payBtn: UIButton!
    
    @IBOutlet var transportV: UIView!
    @IBOutlet var transportFormSV: UIStackView!
    @IBOutlet var escrowV: UIView!
        
    private var isInsuranceSelected = true
    private var escrowFee = 0
    private var insuranceFee = 100
    private var disposeBag: DisposeBag = DisposeBag()
    
    var quotationResp:QuotationResp?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupDefaultValue()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Checkout"
        self.productImage.layer.cornerRadius = 6
        
        self.insuranceChecklistView.layer.cornerRadius = self.insuranceChecklistView.frame.height/2
        self.insuranceChecklistView.layer.borderWidth = 1
        self.insuranceChecklistView.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25).cgColor
        
        self.payBtn.layer.cornerRadius = 6
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    private func setupDefaultValue(){
        
        if let quotationResp = self.quotationResp{
            if let quotation = quotationResp.quotation{
                if let order = quotationResp.order{
                            
                    self.insuranceFeeL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(self.insuranceFee))!
                    
                    if let shippingAddress = quotation.shippingAddress{
                        self.addressTitleL.text = shippingAddress.addressTitle
                        self.fullAddressL.text = shippingAddress.fullAddress
                        
                        self.districtCityProvinceL.text = String(format: "%@, %@, %@", shippingAddress.district, shippingAddress.city?.cityName ?? "", shippingAddress.province?.provinceName ?? "")
                        self.phoneNumberL.text = shippingAddress.phoneNumber
                        self.postalCodeL.text = shippingAddress.postalCode
                        
                    }else{
                        SVProgressHUD.showError(withStatus: "Shipping Address is missing")
                        SVProgressHUD.dismiss(withDelay: Delay.SHORT)
                    }
                    
                    if (quotation.product?.images.count ?? 0) > 0{
                        if let imageUrlString = quotation.product?.images[0].imageUrl{
                            if let imageUrl = URL(string: Network.ASSET_URL + imageUrlString){
                                self.productImage.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholders"))
                            }
                        }
                    }
                    
                    self.productNameL.text = quotation.product?.itemName
                    let productPricePerItem = CurrencyHelper.shared.formatCurrency(price: String(order.pricePerItem)) ?? "0"
                    let unitName = quotation.product?.unit.unitName ?? ""
                    self.productPriceL.text = "Rp" + productPricePerItem + "/" + unitName
                    self.productQuantity.text = String(order.quantity) + " " + unitName
                    
                    if order.shippingName == nil{
                        self.transportV.isHidden = true
                        self.transportFormSV.isHidden = false
                    }else{
                        self.transportV.isHidden = false
                        self.transportFormSV.isHidden = true
                        
                        self.chooseTransportBtn.isHidden = true
                        self.shippingNameTimeEstimationL.text = String(format: "%@ (%d days)", order.shippingName ?? "", order.shippingEstimationTime!)
                        self.shippingFeeL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(order.shippingCost ?? 0))!
                    }
                    
                    self.escrowFee = Int((Double(order.pricePerItem) * Double(order.quantity)) * 0.2)
                    self.escrowFeeL.text = "Rp" +  CurrencyHelper.shared.formatCurrency(price: String(escrowFee))!
                    
                    let totalPayment = (order.pricePerItem * order.quantity) + self.escrowFee + self.insuranceFee + (order.shippingCost ?? 0)
                    self.totalPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(totalPayment))!
                    
                }else{
                    SVProgressHUD.showError(withStatus: "Order is missing")
                    SVProgressHUD.dismiss(withDelay: Delay.SHORT)
                }
            }else{
                SVProgressHUD.showError(withStatus: "Quotation is missing")
                SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            }
        }else{
            SVProgressHUD.showError(withStatus: "QuotationResp is missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    private func observeViewModel(){
        OrderVM.shared.isSuccess.bind { (isConnectSuccess) in
            self.disposeBag = DisposeBag()
            
            SVProgressHUD.showSuccess(withStatus: "Payment success")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        OrderVM.shared.errorMsg.bind { (errorMsg) in
            self.disposeBag = DisposeBag()
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func isValid()->Bool{
        if self.shippingNameTF.text! == ""{
            return false
        }
        
        if self.shippingFeeTF.text! == ""{
            return false
        }
        
        if self.shippingTimeTF.text! == ""{
            return false
        }
        
        return true
    }
    
    @IBAction func insuraceAction(_ sender: Any) {
        if let quotationResp = self.quotationResp, let order = quotationResp.order{
            self.isInsuranceSelected = !self.isInsuranceSelected
            var totalPayment = (order.pricePerItem * order.quantity) + self.escrowFee + (order.shippingCost ?? 0)
            if (self.isInsuranceSelected){
                self.insuranceChecklistView.backgroundColor = Color.PRIMARY_COLOR
                totalPayment += self.insuranceFee
            }else{
                self.insuranceChecklistView.backgroundColor = .white
            }
            self.totalPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(totalPayment))!
        }
    }
    
    @IBAction func payAction(_ sender: Any) {
        if let quotationResp = self.quotationResp, let order = quotationResp.order{
            let totalPayment = (order.pricePerItem * order.quantity) + self.escrowFee + self.insuranceFee + (order.shippingCost ?? 0)
            let manualPaymentVC = ManualPaymentViewController()
            manualPaymentVC.order = order
            manualPaymentVC.totalPayment = totalPayment
            self.navigationController?.pushViewController(manualPaymentVC, animated: true)

        }
//        if let quotationResp = self.quotationResp, let order = quotationResp.order{
//            var orderObj = order
//            if order.shippingName == nil{
//                if self.isValid(){
//                    orderObj = order
//                    orderObj.shippingName = self.shippingNameTF.text!
//                    if let shippingFee = Int(self.shippingFeeTF.text!){
//                        orderObj.shippingCost = shippingFee
//                    }else{
//                        SVProgressHUD.showError(withStatus: "Shipping fee must be a number")
//                        SVProgressHUD.dismiss(withDelay: Delay.SHORT)
//                    }
//
//                    if let shippingTime = Int(self.shippingTimeTF.text!){
//                        orderObj.shippingEstimationTime = shippingTime
//                    }else{
//                        SVProgressHUD.showError(withStatus: "Shipping time must be a number")
//                        SVProgressHUD.dismiss(withDelay: Delay.SHORT)
//                    }
//                }else{
//                    SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
//                    SVProgressHUD.dismiss(withDelay: Delay.SHORT)
//                    return
//                }
//            }
//
//            SVProgressHUD.show()
//            OrderVM.shared.checkoutOrder(order: orderObj, paymentCode: "BCA", paymentCategory: "Virtual Account", isInsurance: self.isInsuranceSelected)
//        }
    }
    
    @IBAction func paymentMethodAction(_ sender: Any) {
        let paymentMethodVC = PaymentMethodViewController()
        paymentMethodVC.delegate = self
        self.navigationController?.pushViewController(paymentMethodVC, animated: true)
    }
    
    @IBAction func selectAddress(_ sender: Any) {
        self.navigationController?.pushViewController(SelectAddressViewController(), animated: true)
    }
    
}

extension CheckoutViewController: CheckoutDelegate{
    // MARK: NOT USED YET
    func didPaymentMethodSelected() {
        self.payBtn.isEnabled = true
        self.payBtn.backgroundColor = Color.ORANGE_COLOR
        self.payBtn.setTitleColor(.white, for: .normal)
    }
}
