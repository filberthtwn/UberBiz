//
//  ListingListViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class ListingListViewController: UberBizViewController {

    @IBOutlet var listingCollectionView: UICollectionView!
    
    private var searchTextField:UITextField?
    private var products: [Product] = []
    private var disposeBag: DisposeBag = DisposeBag()
    
    var subcategory:SubCategory?
//    var searchQuery = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
        self.setupDefaultValue()
    }
    
    private func setupViews(){
        self.searchTF?.textColor = Color.ORANGE_COLOR
        self.listingCollectionView.register(UINib(nibName: "ListingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ListingCell")
    }
    
    private func setupData(){
        if let subcategory = self.subcategory{
            ProductVM.shared.getBuyerProducts(sellerId: nil, subCategoryId: subcategory.id, productName: nil, paginate: 15)
        }else{
            SVProgressHUD.showError(withStatus: "Subcategory missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    private func setupDefaultValue(){
        guard let searchTextField = self.searchTextField else {return}
        searchTextField.text = self.searchQuery
    }
    
    private func observeViewModel(){
        ProductVM.shared.products.bind { (products) in
            self.products = products
            self.listingCollectionView.reloadData()
        }.disposed(by: disposeBag)
        
        ProductVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
        
}

extension ListingListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingCell", for: indexPath) as! ListingCollectionViewCell
        
        if self.products[indexPath.item].images.count > 0{
            if let imageUrlStr = self.products[indexPath.item].images.first?.imageUrl{
                if let imageUrl = URL(string: Network.ASSET_URL + imageUrlStr){
                    cell.productIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                }
            }
        }
        
        cell.productNameL.text = self.products[indexPath.item].itemName
        cell.priceL.text = CurrencyHelper.shared.formatCurrency(price: self.products[indexPath.item].price)
        cell.cityNameL.text = String(format: "%@ %@", self.products[indexPath.item].warehouse?.city?.type ?? "", self.products[indexPath.item].warehouse?.city?.cityName ?? "")
        cell.minimumOrderL.text = String(format: "%d %@", self.products[indexPath.item].weight, self.products[indexPath.item].unit.unitName)
        
        if (indexPath.item == 0 || indexPath.item == 1){
            cell.containerViewTop.constant = 16
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let listingDetailVC = ListingDetailViewController()
        listingDetailVC.product = self.products[indexPath.item]
        self.navigationController?.pushViewController(listingDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.item == 0 || indexPath.item == 1){
            return CGSize(width: self.listingCollectionView.frame.width/2, height: (self.listingCollectionView.frame.width/2) + 72 + 24)
        }else{
            return CGSize(width: self.listingCollectionView.frame.width/2, height: (self.listingCollectionView.frame.width/2) + 72 + 16)
        }
    }
}
