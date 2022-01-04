//
//  CreateRequestViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxSwift
import SVProgressHUD

protocol CreateRequestDelegate{
    func didSelectAddress(address: Address)
    func didSelectSubCategory(subCategory: SubCategory)
    func didSelectUnit(unit: Unit)
}

class CreateRequestViewController: UIViewController {

    @IBOutlet var titleTF: UITextField!
    @IBOutlet var descriptionTF: UITextField!
    @IBOutlet var quantityTF: UITextField!
    
    @IBOutlet var productIV: RoundedImageView!
    
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var productPriceL: UILabel!
    @IBOutlet var categoryNameL: UILabel!
    @IBOutlet var unitNameL: UILabel!
    @IBOutlet var addressL: UILabel!
    @IBOutlet var addAddressL: UILabel!
    @IBOutlet var requestTitleCountL: UILabel!
    @IBOutlet var requestDescCountL: UILabel!
    
    @IBOutlet var productV: UIView!
    @IBOutlet var addressV: UIView!
    
    @IBOutlet var categoryBtn: UIButton!
    @IBOutlet var unitBtn: UIButton!
    
    /// Create request for spesific product
    var selectedProduct: Product?
    
    private var selectedCategory: SubCategory?
    private var selectedUnit: Unit?
    private var selectedAddress: Address?
    private var disposeBag: DisposeBag = DisposeBag()
    private let maxTitleCount = 100
    private let maxDescCount = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.observeViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let address = self.selectedAddress{
            self.addressL.text = address.addressTitle
            self.addAddressL.isHidden = true
            self.addressV.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    private func setupViews(){
        self.title = "Create Request"
        
        productV.isHidden = true
        
        titleTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        descriptionTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        /// Setup Product Section when state from Product Detail
        if let selectedProduct = self.selectedProduct {
            productV.isHidden = false
            if let imageUrlStr = selectedProduct.images.first?.imageUrl, let imageUrl = URL(string: Network.ASSET_URL + imageUrlStr){
                productIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
            }
            productNameL.text = selectedProduct.itemName
            productPriceL.text = String(format: "Rp %@", CurrencyHelper.shared.formatCurrency(price: selectedProduct.price)!)
            
            selectedCategory = selectedProduct.subcategory
            categoryBtn.isEnabled = false
            categoryNameL.text = selectedProduct.subcategory.subCategoryName
            
            selectedUnit = selectedProduct.unit
            unitBtn.isEnabled = false
            unitNameL.text = selectedProduct.unit.unitName
        }
    }
    
    private func observeViewModel(){
        AddressVM.shared.address.bind { (address) in
            
            guard let selectedProduct = self.selectedProduct else { return }
                        
            var quotation = Quotation()
            quotation.price = Int(selectedProduct.price)!
            quotation.quantity = self.quantityTF.text!
            quotation.description = self.descriptionTF.text!
            quotation.product = selectedProduct
            
            QuotationVM.shared.createQuotation(quotation: quotation, shippingAddressId: address.id)
        }.disposed(by: disposeBag)
        
        QuotationVM.shared.quotationResp.bind { (quotationResp) in
            SVProgressHUD.showSuccess(withStatus: "Quotation created successfully")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func isValid()->Bool{
        if self.titleTF.text == nil{
            return false
        }
        
        if self.descriptionTF.text == nil{
            return false
        }
        
        if self.quantityTF.text == nil{
            return false
        }
        
        if selectedCategory == nil{
            return false
        }
        
        if selectedUnit == nil{
            return false
        }
        
        if self.selectedAddress == nil{
            return false
        }
        
        return true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        switch textField {
            case titleTF:
                if titleTF.text!.count > maxTitleCount {
                    titleTF.text!.removeLast()
                }
                requestTitleCountL.text = String(format: "%d/%d", titleTF.text!.count, maxTitleCount)
                break
            case descriptionTF:
                if descriptionTF.text!.count > maxDescCount {
                    descriptionTF.text!.removeLast()
                }
                requestDescCountL.text = String(format: "%d/%d", descriptionTF.text!.count, maxDescCount)
                break
            default:
                break
        }
    }
    
    @IBAction func categoryAction(_ sender: Any) {
        let categoryListVC = AddProductCategoryListViewController()
        categoryListVC.createRequestDelegate = self
        categoryListVC.type = CategoryVCSource.REQUEST
        self.navigationController?.pushViewController(categoryListVC, animated: true)
    }
    
    @IBAction func unitAction(_ sender: Any) {
        let unitListVC = AddProductUnitViewController()
        unitListVC.createRequestDelegate = self
        unitListVC.type = UnitVCSource.REQUEST
        self.navigationController?.pushViewController(unitListVC, animated: true)
    }
    
    @IBAction func addAddressAction(_ sender: Any) {
        let addAddressVC = AddAddressViewController()
        addAddressVC.currentAddress = self.selectedAddress
        addAddressVC.sourceVC = AddAddressSource.REQUEST
        addAddressVC.createRequestDelegate = self
        self.navigationController?.pushViewController(addAddressVC, animated: true)
    }
    
    @IBAction func proceedAction(_ sender: Any) {
        if self.isValid(){
            if selectedProduct != nil  {
                SVProgressHUD.show()
                AddressVM.shared.createAddress(address: selectedAddress!)
                return
            }
            
            var requestQuotation = RequestQuotation()
            requestQuotation.title = self.titleTF.text!
            requestQuotation.description = self.descriptionTF.text!
            requestQuotation.subcategory = selectedCategory
            requestQuotation.unit = selectedUnit
            requestQuotation.quantity = Int(self.quantityTF.text!)!
            requestQuotation.deliveryAddress = self.selectedAddress
            
            let companyListVC = CompanyTargetListViewController()
            companyListVC.requestQuotation = requestQuotation
            self.navigationController?.pushViewController(companyListVC, animated: true)
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
}

extension CreateRequestViewController: CreateRequestDelegate{
    func didSelectSubCategory(subCategory: SubCategory) {
        self.selectedCategory = subCategory
        self.categoryNameL.text = selectedCategory!.subCategoryName
    }
    
    func didSelectUnit(unit: Unit) {
        self.selectedUnit = unit
        self.unitNameL.text = selectedUnit!.unitName
    }
    
    func didSelectAddress(address: Address) {
        self.selectedAddress = address
    }
}
