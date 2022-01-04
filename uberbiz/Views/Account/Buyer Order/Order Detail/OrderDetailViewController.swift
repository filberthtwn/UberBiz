//
//  OrderDetailViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 02/02/21.
//

import UIKit
import SVProgressHUD

enum OrderDetailSourceVC {
    case MY_ORDER, PAYMENT
}

class OrderDetailViewController: UIViewController {

    @IBOutlet var productContainerV: UIView!
    @IBOutlet var requestAgainV: UIView!
    
    @IBOutlet var productIV: UIImageView!
    
    @IBOutlet var statusL: UILabel!
    @IBOutlet var purchaseDateL: UILabel!
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var productPriceL: UILabel!
    @IBOutlet var productTotalPriceL: UILabel!
    @IBOutlet var productQuantityL: UILabel!
    @IBOutlet var buyerNameL: UILabel!
    @IBOutlet var deliveryL: UILabel!
    
    @IBOutlet var shippingAddressTitleL: UILabel!
    @IBOutlet var shippingAddressFullAddressL: UILabel!
    @IBOutlet var shippingAddressDistrictCityProvinceL: UILabel!
    @IBOutlet var shippingAddressPhoneNumberL: UILabel!
    @IBOutlet var shippingAddressZipCodeL: UILabel!
    
    @IBOutlet var paymentMethodL: UILabel!
    @IBOutlet var deliveryFeeL: UILabel!
    @IBOutlet var insuranceL: UILabel!
    @IBOutlet var adminFeeL: UILabel!
    @IBOutlet var totalPaymentL: UILabel!
    
    @IBOutlet var buyerAddressTitleL: UILabel!
    
    var order:Order?
    var sourceVC: OrderDetailSourceVC = .MY_ORDER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupDefaultValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Handle back button action after payment
        /*
         When user tapped back button, view controller pop to ChatViewController by removing
         ManualPaymentVC & CheckoutVC from parent.
         */
        if self.sourceVC == .PAYMENT{
            for vc in self.navigationController!.viewControllers as Array {
                if vc.isKind(of: ManualPaymentViewController.self) || vc.isKind(of: CheckoutViewController.self) {
                    vc.removeFromParent()
                }
            }
        }
    }
    
    private func setupViews(){
        self.title = "Order Detail"
        self.productContainerV.layer.cornerRadius = 6
        self.productContainerV.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.15).cgColor
        self.productContainerV.layer.shadowOpacity = 1
        self.productContainerV.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.productContainerV.layer.shadowRadius = 3
        
        self.requestAgainV.layer.cornerRadius = 6
    }
    
    private func setupDefaultValue(){
        if let order = self.order{
            
            print("ORDER")
            print(order)
            
            self.statusL.text = order.status!.statusName
            
            self.purchaseDateL.text = DateHelper.shared.formatISO8601(newDateFormat: "dd MMMM yyyy, HH:mm", dateString: order.createdAt, timezone: TimeZone(abbreviation: "UTC"))
            
            if order.quotation!.product!.images.count > 0 {
                if let imageUrl = URL(string: Network.ASSET_URL + order.quotation!.product!.images[0].imageUrl){
                    self.productIV.af.setImage(withURL: imageUrl)
                }
            }
            
            self.productNameL.text = order.quotation!.product!.itemName
            self.productPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: order.quotation!.product!.price)! + "/" + order.quotation!.product!.unit.unitName
            self.productQuantityL.text = String(order.quantity) + " " + order.quotation!.product!.unit.unitName
            self.productTotalPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(order.pricePerItem * order.quantity))!

            self.buyerNameL.text = order.quotation!.buyer?.username
            self.deliveryL.text = order.quotation!.shippingName
            self.shippingAddressTitleL.text = order.quotation!.shippingAddress?.addressTitle
            let shippingAddress = String(format: "%@, %@, %@", order.quotation!.shippingAddress?.district ?? "", order.quotation!.shippingAddress?.city?.cityName ?? "", order.quotation!.shippingAddress?.province?.provinceName ?? "")
            self.shippingAddressDistrictCityProvinceL.text = shippingAddress
            
            self.deliveryL.text = order.shippingName ?? "Buyer Shipping"
            self.deliveryFeeL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(order.shippingCost ?? 0))!
            self.insuranceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(order.insurance ?? 0))!
            self.adminFeeL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(order.adminFee ?? 0))!
            let shippingCost = order.shippingCost ?? 0
            let insurance = order.insurance ?? 0
            let totalPrice = shippingCost + insurance + (order.pricePerItem * order.quantity)
            self.totalPaymentL.text = "Rp" +  CurrencyHelper.shared.formatCurrency(price: String(totalPrice))!
        }
    }
    
    @IBAction func productDetailAction(_ sender: Any) {
        if let order = self.order{
            let productDetailVC = ListingDetailViewController()
            productDetailVC.product = order.quotation!.product
            self.navigationController?.pushViewController(productDetailVC, animated: true)
        }else{
            SVProgressHUD.showError(withStatus: "Order object missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
}
