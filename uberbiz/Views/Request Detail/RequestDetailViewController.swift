//
//  RequestDetailViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 15/02/21.
//

import UIKit
import SVProgressHUD

class RequestDetailViewController: UIViewController {

    @IBOutlet var quotationBtnV: UIView!
    
    @IBOutlet var requestTitleL: UILabel!
    @IBOutlet var buyerNameL: UILabel!
    @IBOutlet var shippingAddressL: UILabel!
    @IBOutlet var subCategoryNameL: UILabel!
    @IBOutlet var totalNeedL: UILabel!
    @IBOutlet var descriptionL: UILabel!
    
    @IBOutlet var createQuotationBtnContainerV: UIView!
    
    var userRole = UserRole.BUYER
    var requestQuotation: RequestQuotation?
    var buyerQbUserId: UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
        
    private func setupViews(){
        self.title = "Request Detail"
        self.quotationBtnV.layer.cornerRadius = 6
        
        if self.userRole == UserRole.BUYER{
            self.createQuotationBtnContainerV.isHidden = true
        }else{
            self.view.backgroundColor = .white
            self.createQuotationBtnContainerV.isHidden = false
        }
        
        if let requestQuotation = self.requestQuotation{
            self.requestTitleL.text = requestQuotation.title
            
            let deliveryAddress = String(format: "%@, %@, %@, %@", requestQuotation.deliveryAddress?.fullAddress ?? "", requestQuotation.deliveryAddress?.district ?? "", requestQuotation.deliveryAddress?.city?.cityName ?? "", requestQuotation.deliveryAddress?.province?.provinceName ?? "")
            self.shippingAddressL.text = deliveryAddress
            self.subCategoryNameL.text = requestQuotation.subcategory?.subCategoryName
            self.totalNeedL.text = String(requestQuotation.quantity) + " " + (requestQuotation.unit?.unitName ?? "")
            self.descriptionL.text = requestQuotation.description
        }else{
            SVProgressHUD.showError(withStatus: "Request quotation missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    @IBAction func createQuotationAction(_ sender: Any) {
        let createQuotationVC = CreateQuotationViewController()
        createQuotationVC.shippingAddressId = self.requestQuotation?.deliveryAddressId
        createQuotationVC.buyerQbUserId = self.buyerQbUserId
        self.navigationController?.pushViewController(createQuotationVC, animated: true)
    }
    
}
