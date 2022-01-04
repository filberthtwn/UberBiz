//
//  ListingDetailViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage
import SVProgressHUD

struct ProductDetailSource {
    static var LISTING = "LISTING"
    static var MY_PRODUCT = "MY_PRODUCT"
}

class ListingDetailViewController: UIViewController {

    @IBOutlet var productImageCollectionView: UICollectionView!
    @IBOutlet var imagePaginationView: UIView!
    
    @IBOutlet var heartImageView: UIImageView!
    @IBOutlet var verifiedIV: UIImageView!
    
    @IBOutlet var heartView: UIView!
    @IBOutlet var listingFooterView: UIStackView!
    
    @IBOutlet var trashView: UIView!
    @IBOutlet var editButton: UberBizButton!
    @IBOutlet var myProductFooterView: UIView!
    
    @IBOutlet var priceL: UILabel!
    @IBOutlet var productNameL: UILabel!
    @IBOutlet var storeNameL: UILabel!
    @IBOutlet var cityNameL: UILabel!
    @IBOutlet var ratingL: UILabel!
    @IBOutlet var weightL: UILabel!
    @IBOutlet var unitL: UILabel!
    @IBOutlet var minimumOrderL: UILabel!
    @IBOutlet var categoryNameL: UILabel!
    @IBOutlet var productDescL: UILabel!
    @IBOutlet var totalImageL: UILabel!
    
    @IBOutlet var wishlistBtn: UIButton!
    
    private var imageUrls:[String] = []
    private let wishlistVM = WishlistVM()
    
    var type = ProductDetailSource.LISTING
    var product:Product?
    
    private var productDesc: String?
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isMovingFromParent{
            self.disposeBag = DisposeBag()
        }
    }
    
    private func setupViews(){
        self.title = "Product Detail"
        self.productImageCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        
        self.imagePaginationView.layer.cornerRadius = self.imagePaginationView.frame.height/2
        
        if (self.type == ProductDetailSource.LISTING){
            self.listingFooterView.isHidden = false
            self.myProductFooterView.isHidden = true
            self.heartView.isHidden = false
        }else{
            self.listingFooterView.isHidden = true
            self.myProductFooterView.isHidden = false
            self.heartView.isHidden = true
            
            self.trashView.layer.cornerRadius = 6
            self.trashView.layer.borderWidth = 1
            self.trashView.layer.borderColor =  UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.15).cgColor
        }
    }
    
    private func setupData(){
        guard let product = self.product else {return}
        self.priceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: product.price)! + "/ " + product.unit.unitName
        self.productNameL.text = product.itemName
        self.weightL.text = String(product.weight)
        self.unitL.text = product.unit.unitName
        self.storeNameL.text = product.seller!.storeName ?? "Unknown"
        if product.seller!.isVerified == 0{
            self.verifiedIV.isHidden = true
        }else{
            self.verifiedIV.isHidden = false
        }
        
        if let warehouse = product.warehouse{
            if let city = warehouse.city{
                self.cityNameL.text = city.type + " " + city.cityName
            }
        }
        
        if let rating = product.seller!.rating{
            self.ratingL.text = String(format: "%.1f/5", rating)
        }
        
        self.minimumOrderL.text = String(product.minimumOrder) + " " + product.unit.unitName
        self.categoryNameL.text = product.subcategory.subCategoryName
        self.productDescL.text = product.itemDescription
        productDesc = product.itemDescription
        
        for image in product.images {
            self.imageUrls.append(image.imageUrl)
        }
        self.productImageCollectionView.reloadData()
        if product.images.count > 0{
            self.totalImageL.text = "1 / " + String(product.images.count)
        }else{
            self.totalImageL.text = "0 / " + String(product.images.count)
        }
        if product.isWishlisted ?? false{
            self.heartImageView.tintColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        }
        
        if self.type == ProductDetailSource.LISTING{
            if product.deletedAt != nil || !Bool(truncating: NSNumber(value: product.isAccessable)){
                let unavailableVC = UnavailableListingViewController()
                unavailableVC.delegate = self
                unavailableVC.modalTransitionStyle = .crossDissolve
                unavailableVC.modalPresentationStyle = .overCurrentContext
                self.present(unavailableVC, animated: false, completion: nil)
            }
        }
        
    }
    
    private func observeViewModel(){
        wishlistVM.isSuccess.bind { (wishlist) in
            self.wishlistBtn.isEnabled = true
        }.disposed(by: disposeBag)
        
        wishlistVM.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}

            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
        
        ProductVM.shared.isSuccess.bind { (isSuccess) in
            SVProgressHUD.showSuccess(withStatus: "Product deleted successfully")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            self.navigationController?.popViewController(animated: true)    
        }.disposed(by: disposeBag)
        
        ProductVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}

            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func storeDetailAction(_ sender: Any) {
        if let product = self.product{
            let reviewHeaderVC = StoreReviewViewController()
            reviewHeaderVC.seller = product.seller
            self.navigationController?.pushViewController(reviewHeaderVC, animated: true)
        }
        
    }
    
    @IBAction func wishlistAction(_ sender: Any) {
        self.wishlistBtn.isEnabled = false
        if let product = self.product{
            if !(product.isWishlisted ?? false){
                self.heartImageView.tintColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                self.product?.isWishlisted = true
                wishlistVM.createWishlist(product: product)
            }else{
                self.heartImageView.tintColor = UIColor(red: 135/255, green: 142/255, blue: 158/255, alpha: 1)
                self.product?.isWishlisted = false
                wishlistVM.deleteWishlist(product: product)
            }
        }else{
            SVProgressHUD.showError(withStatus: "Product is missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    @IBAction func productDescAction(_ sender: Any) {
        let productDescVC = ProductDescriptionViewController()
        productDescVC.desc = productDesc
        productDescVC.sourceVC = ProductDescSourceVC.EDIT
        self.navigationController?.pushViewController(productDescVC, animated: true)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if let product = self.product{
            SVProgressHUD.show()
            ProductVM.shared.deleteProduct(product: product)
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        let addProductVC = AddProductViewController()
        addProductVC.product = self.product
        addProductVC.sourceVC = AddProductType.UPDATE
        self.navigationController?.pushViewController(addProductVC, animated: true)
    }
    
    @IBAction func orderNowAction(_ sender: Any) {
        let createRequestVC = CreateRequestViewController()
        createRequestVC.selectedProduct = product
        self.navigationController?.pushViewController(createRequestVC, animated: true)
    }
}

extension ListingDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.productImageCollectionView.frame.width, height: self.productImageCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.imageUrls.count > 0{
            return self.imageUrls.count
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        if self.imageUrls.count > 0{
            if let imageUrl = URL(string: Network.ASSET_URL + self.imageUrls[indexPath.item]){
                cell.imageIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
            }
        }else{
            cell.imageIV.image = UIImage(named: "img_placeholder")
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x/view.frame.width
        self.totalImageL.text = String(Int(index) + 1) + " / " + String(self.imageUrls.count)
    }
}

extension ListingDetailViewController: UnavailableListingProtocol{
    func didDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}
