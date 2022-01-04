//
//  AddProductViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

//struct AddProductItem{
//    static var selectedCategory:SubCategory?
//    static var selectedUnit:Unit?
////    static var selectedAddress:Address?
//    static var productDesc:String?
//}

struct AddProductType {
    static let CREATE = "CREATE"
    static let UPDATE = "UPDATE"
}

protocol AddProductDelegate {
    func deleteImage(index:Int)
    func didSelectCategory(subCategory: SubCategory)
    func didSelectUnit(unit: Unit)
    func didChangeDesc(desc: String)
    func didSelectAddress(address: Address)
}

class AddProductViewController: UIViewController {

    @IBOutlet var productImageCollectionView: UICollectionView!
    @IBOutlet var createProductButton: UberBizButton!
    
    @IBOutlet var productTitleTF: UITextField!
    @IBOutlet var weightTF: UITextField!
    @IBOutlet var priceTF: UITextField!
    @IBOutlet var minimumOrderTF: UITextField!
    
    @IBOutlet var productTitleLengthL: UILabel!
    @IBOutlet var productDescL: UILabel!
    @IBOutlet var categoryL: UILabel!
    @IBOutlet var unitL: UILabel!
    @IBOutlet var addAddressL: UILabel!
    @IBOutlet var addressTitleL: UILabel!
        
    @IBOutlet var addressV: UIView!
    @IBOutlet var productStatusV: UIView!
    
    @IBOutlet var statusSwitch: UISwitch!
    
    private var productDesc: String?
    private var selectedSubCategory: SubCategory?
    private var selectedUnit: Unit?

    private var productImages:[ProductImage] = []
    private var disposeBag:DisposeBag = DisposeBag()
    private let maxTitleCount = 100
    
    var product:Product?
    var sourceVC = AddProductType.CREATE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupDefaultValue()
        self.observeViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if let address = self.product?.warehouse{
            self.addAddressL.isHidden = true
            self.addressV.isHidden = false
            
            self.addressTitleL.text = address.addressTitle
        }
    }
    
    private func setupViews(){
        self.title = "Add Product"
        self.productImageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        self.productImageCollectionView.register(UINib(nibName: "AddProductImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        self.productImageCollectionView.register(UINib(nibName: "AddProductNewImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewImageCell")
        
        if self.sourceVC == AddProductType.CREATE{
            self.productStatusV.isHidden = true
        }else{
            self.productStatusV.isHidden = false
            self.statusSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: UIControl.Event.valueChanged)
        }
        
        productTitleTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupDefaultValue(){
        if let product = self.product{
            
            self.title = "Update Product"
            
            for image in product.images {
                self.productImages.append(image)
            }
            self.productImageCollectionView.reloadData()
            
            self.productTitleTF.text = product.itemName
            productTitleLengthL.text = String(format: "%d/%d", product.itemName.count, maxTitleCount)
            
            self.productDescL.text = product.itemDescription
            self.productDescL.textColor = .black
            productDesc = product.itemDescription
            
            selectedSubCategory = product.subcategory
            self.categoryL.text = product.subcategory.subCategoryName
            
            weightTF.text = String(product.weight)
            selectedUnit = product.unit
            self.unitL.text = product.unit.unitName
            self.priceTF.text = product.price
            self.minimumOrderTF.text = String(product.minimumOrder)
            
            if let warehouse = product.warehouse{
                self.addAddressL.isHidden = true
                self.addressV.isHidden = false
                
                self.addressTitleL.text = warehouse.addressTitle
            }
            
            self.statusSwitch.isOn = Bool(truncating: NSNumber(value: product.isAccessable))
        }
    }
    
    private func observeViewModel(){
        ProductVM.shared.image.bind { (image) in
            SVProgressHUD.dismiss()
            
            self.productImages.append(image)
            self.productImageCollectionView.reloadData()
        }.disposed(by: disposeBag)
        
        ProductVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func isValid()->Bool{
        
        if self.productImages.count <= 0 {
            return false
        }
        
        if self.productTitleTF.text! == ""{
            return false
        }
        
        if self.weightTF.text! == ""{
            return false
        }
        
        if selectedSubCategory == nil{
            return false
        }
        
        if selectedUnit == nil{
            return false
        }
        
        if let product = self.product{
            if product.warehouse == nil{
                return false
            }
        }
        
        if productDesc == nil{
            return false
        }

        return true
        
    }
    
    private func setupProductObject(){
        var product = Product()
        
        product.images = self.productImages
        product.itemName = self.productTitleTF.text!
        product.itemDescription = productDesc ?? ""
        if let subCategory = selectedSubCategory{
            product.subcategory = subCategory
        }
        if let unit = selectedUnit{
            product.unit = unit
        }
        if self.weightTF.text != ""{
            product.weight = Int(self.weightTF.text!)!
        }
        product.price = self.priceTF.text!
        if self.minimumOrderTF.text != ""{
            product.minimumOrder = Int(self.minimumOrderTF.text!)!
        }
        product.warehouse = self.product?.warehouse
        
        self.product = product
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        if productTitleTF.text!.count > maxTitleCount {
            productTitleTF.text!.removeLast()
        }
        productTitleLengthL.text = String(format: "%d/%d", productTitleTF.text!.count, maxTitleCount)
    }
    
    @objc private func switchChanged(_ sender: UISwitch){
        self.product?.isAccessable = sender.isOn
    }
    
    @IBAction func addDescriptionAction(_ sender: Any) {
        self.setupProductObject()
        let productDescVC = ProductDescriptionViewController()
        productDescVC.desc = productDesc
        productDescVC.productFormDelegate = self
        self.navigationController?.pushViewController(productDescVC, animated: true)
    }
    
    @IBAction func categoryAction(_ sender: Any) {
        self.setupProductObject()
        let subCategoryVC = AddProductCategoryListViewController()
        subCategoryVC.productFormDelegate = self
        self.navigationController?.pushViewController(subCategoryVC, animated: true)
    }
    
    @IBAction func unitAction(_ sender: Any) {
        self.setupProductObject()
        let unitVC = AddProductUnitViewController()
        unitVC.productFormDelegate = self
        self.navigationController?.pushViewController(unitVC, animated: true)
    }
    
    @IBAction func addAddressAction(_ sender: Any) {
        self.setupProductObject()
        
        let addAddressVC = AddAddressViewController()
        addAddressVC.addProductDelegate = self
        addAddressVC.currentAddress = self.product?.warehouse
        addAddressVC.sourceVC = AddAddressSource.CREATE_PRODUCT
        self.navigationController?.pushViewController(addAddressVC, animated: true)
    }
    
    @IBAction func selectDeliveryDesctinationAction(_ sender: Any) {
        
        if self.isValid(){
            var product = Product()
            
            product.images = self.productImages
            product.itemName = self.productTitleTF.text!
            product.itemDescription = productDesc ?? ""
            product.subcategory = selectedSubCategory!
            product.unit = selectedUnit!
            product.weight = Int(self.weightTF.text!)!
            product.price = self.priceTF.text!
            product.minimumOrder = Int(self.minimumOrderTF.text!)!
            product.warehouse = self.product?.warehouse
            product.isAccessable = self.product?.isAccessable ?? false
            
            if let selectedProduct = self.product{
                product.id = selectedProduct.id
                product.shippingCities = selectedProduct.shippingCities
            }
            
            let deliveryDestinationVC = AddProductTargetLocationViewController()
            // MARK: Tell desination VC current state is update
            if let product = self.product, product.id != -1{
                deliveryDestinationVC.type = AddProductType.UPDATE
            }
            deliveryDestinationVC.product = product
            self.navigationController?.pushViewController(deliveryDestinationVC, animated: true)
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
        
    }
}

extension AddProductViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < self.productImages.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! AddProductImageCollectionViewCell
            if let url = URL(string: Network.ASSET_URL + self.productImages[indexPath.item].imageUrl){
                cell.productImageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "img_placeholder"))
            }
            cell.delegate = self
            cell.index = indexPath.item
            cell.prepareForReuse()
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewImageCell", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == self.productImages.count{
            let alert = UIAlertController(title: "Upload Image", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
                self.presentImagePickerController(sourceType: .camera)
            }))
            alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
                self.presentImagePickerController(sourceType: .photoLibrary)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func presentImagePickerController(sourceType: UIImagePickerController.SourceType){
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = sourceType
        imagePickerVC.delegate = self
        imagePickerVC.modalPresentationStyle = .fullScreen
        
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .systemBlue
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        self.present(imagePickerVC, animated: true)
    }
}

extension AddProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        SVProgressHUD.show()
        ProductVM.shared.uploadProductImage(image: image)

        self.view.layoutIfNeeded()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
    }
}

extension AddProductViewController: AddProductDelegate{
    func didSelectCategory(subCategory: SubCategory) {
        categoryL.text = subCategory.subCategoryName
        selectedSubCategory = subCategory
    }
    
    func didSelectUnit(unit: Unit) {
        unitL.text = unit.unitName
        selectedUnit = unit
    }
    
    func didChangeDesc(desc: String) {
        productDescL.text = desc
        productDesc = desc
    }
    
    func didSelectAddress(address: Address) {
        self.product?.warehouse = address
    }
    
    func deleteImage(index: Int) {
        self.productImages.remove(at: index)
        self.productImageCollectionView.reloadData()
    }
}
