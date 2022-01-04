//
//  AddAddressViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import SVProgressHUD

struct AddAddressSource {
    static let CREATE_PRODUCT = "CREATE_PRODUCT"
    static let MY_PRODUCT = "MY_PRODUCT"
    static let EDIT_PROFILE = "EDIT_PROFILE"
    static let REQUEST = "REQUEST"
}

protocol AddAddressDelegate {
    func didSelectProvince(province: Province)
    func didSelectCity(city:City)
}

class AddAddressViewController: UIViewController {

    @IBOutlet var addressNameTextField: UITextField!
    
    @IBOutlet var fullAddressTV: UberBizTextView!
    @IBOutlet var districtTF: UITextField!
    @IBOutlet var postalCodeTF: UITextField!
    @IBOutlet var phoneNumberTF: UITextField!
    
    @IBOutlet var provinceNameL: UILabel!
    @IBOutlet var cityNameL: UILabel!
    
    @IBOutlet var saveBtn: UIButton!
    
//    private var selectedProvince: Province?
//    private var selectedCity:City?
    
    var currentAddress:Address?
    
    var addProductDelegate: AddProductDelegate?
    var editStoreDelegate: EditStoreDelegate?
    var createRequestDelegate: CreateRequestDelegate?
    var sourceVC: String = AddAddressSource.MY_PRODUCT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    private func setupViews(){
        self.title = "Add Address"
        
        self.fullAddressTV.placeholder = "Full Address"
//        fullAddressTV.becomeFirstResponder()
//        self.fullAddressTV.selectedTextRange = self.fullAddressTV.textRange(from: self.fullAddressTV.beginningOfDocument, to: self.fullAddressTV.beginningOfDocument)

        self.fullAddressTV.textContainer.lineFragmentPadding = 0
        self.fullAddressTV.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        self.saveBtn.layer.cornerRadius = 10
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        if self.isMovingFromParent{
//            AddAddressItem.selectedProvince = nil
//            AddAddressItem.selectedCity = nil
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentAddress = self.currentAddress{
            self.addressNameTextField.text = currentAddress.addressTitle
            self.fullAddressTV.text = currentAddress.fullAddress

            self.districtTF.text = currentAddress.district
            self.postalCodeTF.text = currentAddress.postalCode
            self.phoneNumberTF.text = currentAddress.phoneNumber
            
            self.provinceNameL.text = currentAddress.province?.provinceName ?? "Select Province"
            self.cityNameL.text = currentAddress.city?.cityName ?? "Select City"
        }
    }
    
    private func isValid()->Bool{
        if self.addressNameTextField.text == ""{
            return false
        }
        
        if self.fullAddressTV.text == ""{
            return false
        }
        
        if let currentAddress = self.currentAddress{
            if currentAddress.city == nil{
                return false
            }
            
            if currentAddress.province == nil{
                return false
            }
        }else{
            return false
        }
        
        if self.districtTF.text == ""{
            return false
        }
        
        if self.postalCodeTF.text == ""{
            return false
        }
        
        if self.phoneNumberTF.text == ""{
            return false
        }
        
        return true
    }
    
    private func setupCurrentAddress(){
        var address = Address()
        address.addressTitle = self.addressNameTextField.text!
        address.fullAddress = self.fullAddressTV.text!
        address.city = self.currentAddress?.city
        address.province = self.currentAddress?.province
        address.district = self.districtTF.text!
        address.postalCode = self.postalCodeTF.text!
        address.phoneNumber = self.phoneNumberTF.text!
        
        self.currentAddress = address
    }

    @IBAction func provinceAction(_ sender: Any) {
        
        self.setupCurrentAddress()
        
        let provinceListVC = ProvinceListViewController()
        provinceListVC.delegate = self
        self.navigationController?.pushViewController(provinceListVC, animated: true)
    }
    
    @IBAction func cityAction(_ sender: Any) {
        
        self.setupCurrentAddress()
        
        let cityListVC = CityListViewController()
        cityListVC.selectedProvince = self.currentAddress?.province
        cityListVC.delegate = self
        self.navigationController?.pushViewController(cityListVC, animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if self.isValid(){
            self.setupCurrentAddress()
            
            switch self.sourceVC {
            case AddAddressSource.CREATE_PRODUCT:
                self.addProductDelegate?.didSelectAddress(address: self.currentAddress!)
            case AddAddressSource.MY_PRODUCT:
                break
//                self.addProductDelegate?.didSelectAddress(address: self.currentAddress!)
            case AddAddressSource.EDIT_PROFILE:
                self.editStoreDelegate?.didSelectAddress(address: self.currentAddress!)
            case AddAddressSource.REQUEST:
                self.createRequestDelegate?.didSelectAddress(address: self.currentAddress!)
            default:
                break
            }
            
            self.navigationController?.popViewController(animated: true)
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
}

extension AddAddressViewController: AddAddressDelegate{
    func didSelectProvince(province: Province) {
        self.currentAddress?.province = province
        self.currentAddress?.city = nil
    }
    
    func didSelectCity(city: City) {
        self.currentAddress?.city = city
    }
}
