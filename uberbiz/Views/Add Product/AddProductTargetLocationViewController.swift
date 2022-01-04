//
//  AddProductTargetLocationViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/02/21.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

struct DestinationItem {
    var isOpened:Bool = false
    var province:Province?
    var cities:[City] = []
}

protocol DestinationListProtocol{
    func didRadioButtonTapped(section:Int, index: Int)
}

class AddProductTargetLocationViewController: UIViewController {

    @IBOutlet var destinationTableV: UITableView!
    @IBOutlet var searchTF: UberbizTextField!
    
    @IBOutlet var proceedBtn: UIButton!
    
    @IBOutlet var totalSelectedCityL: UILabel!
    
    private var destinationItems:[DestinationItem] = []
    
    private var provinces:[Province] = []
    private var cities:[City] = []
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var selectedAllProvince:[Province] = []
    private var selectedCities:[City] = []
    
    private var isDataLoaded = false
    
    var type:String = AddProductType.CREATE
    
    var product:Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupDefaultValue()
        
        self.setupData()
        self.observeViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        self.title = "Available Shipping"
        self.searchTF.layer.cornerRadius = 6
        self.searchTF.layer.borderWidth = 1
        self.searchTF.layer.borderColor = Color.BORDER_COLOR
        
        self.destinationTableV.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.destinationTableV.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: "DestinationCell")
        
        self.searchTF.addTarget(self, action: #selector(didValueChange(_:)), for: .editingChanged)
    
        self.proceedBtn.layer.cornerRadius = 6
    }
    
    private func setupDefaultValue(){
//        if let product = self.product{
//            for shippingCity in product.shippingCities! {
//                self.selectedCities.append(shippingCity.city)
//            }
//            self.destinationTableV.reloadData()
//        }
    }
    
    private func setupData(){
        UserVM.shared.getProvinces()
    }
    
    private func observeViewModel(){
        UserVM.shared.provinces.bind { (provinces) in
            self.provinces = provinces
            UserVM.shared.getCities(province: nil)
        }.disposed(by: disposeBag)
        
        UserVM.shared.cities.bind { (cities) in
//            self.disposeBag = DisposeBag()
            self.cities = cities
                    
            let destinationItem = DestinationItem()
            self.destinationItems.append(destinationItem)
            
            for province in self.provinces{
                var destinationItem = DestinationItem()
                destinationItem.province = province
                destinationItem.cities = self.cities.filter({$0.provinceId == province.id})
                self.destinationItems.append(destinationItem)
            }
            
           
            if let product = self.product, let shippingCities = product.shippingCities{
                //MARK: Handle update product
                for itemLoc in shippingCities {
                    self.selectedCities.append(itemLoc.city)
                    //MARK: Handle selected all cities on country
                    if self.selectedCities.count == self.cities.count{
                        self.selectedAllProvince = self.provinces
                    }else{
                        //MARK: Handle selected all cities on province
                        let count = product.shippingCities?.filter({$0.city.provinceId == itemLoc.city.provinceId}).count
                        if let destinationItem = self.destinationItems.first(where: {$0.province?.id == itemLoc.city.provinceId}){
                            if count == destinationItem.cities.count{
                                if let province = destinationItem.province{
                                    self.selectedAllProvince.append(province)
                                }else{
                                    SVProgressHUD.showError(withStatus: "Province is missing")
                                    SVProgressHUD.dismiss(withDelay: Delay.SHORT)
                                }
                            }
                        }else{
                            SVProgressHUD.showError(withStatus: "Destiantion item is missing")
                            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
                        }
                    }
                }
            }else{
                //MARK: Handle create product
                self.selectedAllProvince = self.provinces
                self.selectedCities = self.cities
            }
                        
            self.isDataLoaded = true
            self.destinationTableV.reloadData()
            
            self.totalSelectedCityL.text = String(self.selectedCities.count) + " city selected"
        }.disposed(by: disposeBag)
        
        ProductVM.shared.isSuccess.bind { (isSuccess) in
            SVProgressHUD.showSuccess(withStatus: "Product created successfully")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            
            self.disposeBag = DisposeBag()
            
            for viewController in (self.navigationController!.viewControllers as Array).reversed() {
                
                if viewController.isKind(of: MyProductViewController.self) {
                    self.navigationController!.popToViewController(viewController, animated: true)
                    break
                }else if viewController.isKind(of: TabBarViewController.self){
                    self.navigationController!.popToViewController(viewController, animated: true)
                    break
                }
                
                
            }
        }.disposed(by: disposeBag)
        
        AddressVM.shared.address.bind { (warehouse) in
            if let product = self.product{
                var product = product
                product.warehouse?.id = warehouse.id
                                
                var itemLocations:[ItemLocation] = []
                for city in self.selectedCities {
                    let itemLocation = ItemLocation()
                    itemLocation.city = city
                    itemLocations.append(itemLocation)
                }
                product.shippingCities = itemLocations
                if self.type == AddProductType.CREATE{
                    ProductVM.shared.createProduct(product: product)
                }else{
                    ProductVM.shared.updateProduct(product: product)
                }
            }
        }.disposed(by: disposeBag)
        
        AddressVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func proceedAction(_ sender: Any) {
        if let product = self.product{
            SVProgressHUD.show()
            if let address = product.warehouse{
                AddressVM.shared.createAddress(address: address)
            }
        }else{
            SVProgressHUD.showError(withStatus: "Product is missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    @objc private func didValueChange(_ textField:UITextField){
        self.destinationItems.removeAll()
        
        var provinces = self.provinces.filter({(($0.provinceName.lowercased().range(of: textField.text!.lowercased())) != nil)})
        
        if textField.text! == ""{
            provinces = self.provinces
        }
        
        let destinationItem = DestinationItem()
        self.destinationItems.append(destinationItem)
        
        for province in provinces{
            var destinationItem = DestinationItem()
            destinationItem.province = province
            destinationItem.cities = self.cities.filter({$0.provinceId == province.id})
            self.destinationItems.append(destinationItem)
        }
        
        self.destinationTableV.reloadData()
    }

}

extension AddProductTargetLocationViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isDataLoaded {
            return self.destinationItems.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded {
            if self.destinationItems[section].isOpened == true{
                if section != 0{
                    return self.destinationItems[section].cities.count + 2
                }
                return 1
            }else{
                return 1
            }
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 16))
        view.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 244/255, alpha: 0.25)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isDataLoaded == true{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationCell", for: indexPath) as! DestinationTableViewCell
            cell.delegate = self
            
            if indexPath.section == 0{
                cell.textL.text = "Select All City"
                cell.chevronDownIV.isHidden = true
                cell.radioBtnV.isHidden = false
                cell.lineV.isHidden = true
                cell.section = indexPath.section
                cell.index = indexPath.item
                cell.textL.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                if self.selectedCities.count == self.cities.count && self.selectedAllProvince.count == self.provinces.count{
                    cell.isSelect = true
                }else{
                    cell.isSelect = false
                }
            }else{
                if indexPath.item == 0{
                    cell.textL.text = self.destinationItems[indexPath.section].province?.provinceName
                    cell.chevronDownIV.isHidden = false
                    cell.radioBtnV.isHidden = true
                    cell.lineV.isHidden = true
                    
                    cell.textL.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                }else{
                    if indexPath.item == 1{
                        cell.textL.text = "Select All City"
                        if self.selectedAllProvince.contains(where: {$0.id == self.destinationItems[indexPath.section].province!.id}){
                            cell.isSelect = true
                        }else{
                            cell.isSelect = false
                        }
                    }else{
                        cell.textL.text = self.destinationItems[indexPath.section].cities[indexPath.item-2].cityName
                        if self.selectedCities.contains(where: {$0.id == self.destinationItems[indexPath.section].cities[indexPath.item-2].id}){
                            cell.isSelect = true
                        }else{
                            cell.isSelect = false
                        }
                    }
                    
                    cell.textL.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                    cell.chevronDownIV.isHidden = true
                    
                    cell.section = indexPath.section
                    cell.index = indexPath.item
                    cell.radioBtnV.isHidden = false
                    
                    if indexPath.item <= self.destinationItems[indexPath.section].cities.count{
                        cell.lineV.isHidden = false
                    }
                    
                }
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isDataLoaded{
            if indexPath.item == 0{
                if self.destinationItems[indexPath.section].isOpened == true{
                    self.destinationItems[indexPath.section].isOpened = false
                    let sections = IndexSet.init(integer: indexPath.section)
                    self.destinationTableV.reloadSections(sections, with: .automatic)
                }else{
                    self.destinationItems[indexPath.section].isOpened = true
                    let sections = IndexSet.init(integer: indexPath.section)
                    self.destinationTableV.reloadSections(sections, with: .automatic)
                }
            }
        }
    }
}

extension AddProductTargetLocationViewController:DestinationListProtocol{
    func didRadioButtonTapped(section:Int, index: Int) {
        if section == 0{
            if self.selectedAllProvince.count == self.provinces.count && self.selectedCities.count == self.cities.count{
                self.selectedAllProvince.removeAll()
                self.selectedCities.removeAll()
                self.totalSelectedCityL.text = "0 city selected"
            }else{
                self.selectedAllProvince = self.provinces
                self.selectedCities = self.cities
                self.totalSelectedCityL.text = String(self.selectedCities.count) + " city selected"
            }
        }else{
            if index == 1{
                if self.selectedAllProvince.contains(where: {$0.id == self.destinationItems[section].province!.id}){
                    self.selectedAllProvince.removeAll(where: {$0.id == self.destinationItems[section].province!.id})
                }else{
                    self.selectedAllProvince.append(self.destinationItems[section].province!)
                }
                
                for city in self.destinationItems[section].cities{
                    if self.selectedAllProvince.contains(where: {$0.id == self.destinationItems[section].province!.id}){
                        self.selectedCities.append(city)
                    }else{
                        self.selectedCities.removeAll(where: {$0.id == city.id})
                    }
                }
            }else{
                if self.selectedCities.contains(where: {$0.id == self.destinationItems[section].cities[index-2].id}){
                    self.selectedCities.removeAll(where: {$0.id == self.destinationItems[section].cities[index-2].id})
                }else{
                    self.selectedCities.append(self.destinationItems[section].cities[index-2])
                }
            }
            self.totalSelectedCityL.text = String(self.selectedCities.count) + " city selected"
        }
        self.destinationTableV.reloadData()
    }
}
