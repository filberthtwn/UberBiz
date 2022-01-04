//
//  QuotationDetailViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 30/03/21.
//

import UIKit
import SVProgressHUD

class QuotationDetailViewController: UIViewController {

    @IBOutlet var addressTitleL: UILabel!
    @IBOutlet var fullAddressL: UILabel!
    @IBOutlet var districtCityProvinceL: UILabel!
    @IBOutlet var phoneNumberL: UILabel!
    @IBOutlet var postalCodeL: UILabel!
    
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var productPriceL: UILabel!
    @IBOutlet var productQuantityL: UILabel!
    
    @IBOutlet var transportNameL: UILabel!
    @IBOutlet var transportFeeL: UILabel!
    
    @IBOutlet var totalPaymentL: UILabel!
    
    var quotationResp: QuotationResp?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupValue()
    }
    
    private func setupViews(){
        self.title = "Quotation Detail"
    }
    
    private func setupValue(){
        if let quotationResp = self.quotationResp, let quotation = quotationResp.quotation, let order = quotationResp.order{
            
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
            
            if let product = quotation.product{
                self.productNameL.text = product.itemName
                let productPricePerItem = CurrencyHelper.shared.formatCurrency(price: String(order.pricePerItem)) ?? "0"
                let unitName = quotation.product?.unit.unitName ?? ""
                self.productPriceL.text = "Rp" + productPricePerItem + "/" + unitName
                self.productQuantityL.text = String(order.quantity) + " " + unitName
            }else{
                SVProgressHUD.showError(withStatus: "Product is missing")
                SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            }
            
            if let shippingName = quotation.shippingName, let shippingTimeEstimation = quotation.shippingTimeEstimation, let shippingFee = quotation.shippingCost{
                self.transportNameL.text = String(format: "%@ (%d days)", shippingName, shippingTimeEstimation)
                self.transportFeeL.text = CurrencyHelper.shared.formatCurrency(price: String(shippingFee))
            }else{
                self.transportNameL.text = "-"
                self.transportFeeL.isHidden = true
            }
            
            let totalPayment = (order.pricePerItem * order.quantity) + (quotation.shippingCost ?? 0)
            self.totalPaymentL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(totalPayment))!
        }else{
            self.navigationController?.popViewController(animated: true)
            SVProgressHUD.showError(withStatus: "Quotation is missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }

}
