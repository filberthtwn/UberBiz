//
//  NewListingViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit
import SVProgressHUD
import RxCocoa
import RxSwift

class NewListingViewController: UIViewController {
    
    @IBOutlet var newListingCollectionView: UICollectionView!
    @IBOutlet var emptyStateL: UILabel!
    
    private var products:[Product] = []

    private var isDataLoaded = false
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "New Listing"
        self.newListingCollectionView.register(UINib(nibName: "ListingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ListingCell")
        self.newListingCollectionView.register(UINib(nibName: "ShimmerListingCollectionViewCell", bundle: nil),   forCellWithReuseIdentifier: "ShimmerListingCell")
        //        self.newListingCollectionView.constant = (311 * 2) + 16
    }
    
    private func setupData(){
        ProductVM.shared.getBuyerProducts(sellerId: nil, subCategoryId: nil, productName: nil, paginate: 100)
    }
    
    private func observeViewModel(){
        ProductVM.shared.products.bind { (products) in
            self.products = products
            self.isDataLoaded = true
                            
            self.newListingCollectionView.reloadData()
            
            if (self.products.count <= 0){
                self.emptyStateL.isHidden = false
            }
            
        }.disposed(by: disposeBag)
        
        ProductVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
                        
            self.isDataLoaded = true

            self.emptyStateL.isHidden = false
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
}

extension NewListingViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.products.count
        }else{
            return 8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isDataLoaded{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingCell", for: indexPath) as! ListingCollectionViewCell
            cell.layoutIfNeeded()
            
            cell.productNameL.text = self.products[indexPath.item].itemName
            
            if let price = CurrencyHelper.shared.formatCurrency(price: self.products[indexPath.item].price){
                cell.priceL.text = "Rp. " + price
            }
            
            if let warehouse = self.products[indexPath.item].warehouse{
                cell.cityNameL.text = warehouse.city!.type + " " + warehouse.city!.cityName
            }else {
                cell.cityNameL.text = "-"
            }
            
            cell.minimumOrderL.text = String(self.products[indexPath.item].minimumOrder) + " " + self.products[indexPath.item].unit.unitName
            if self.products[indexPath.item].images.count > 0{
                if let imageUrl = URL(string: Network.ASSET_URL + self.products[indexPath.item].images[0].imageUrl){
                    cell.productIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                }
            }else{
                cell.productIV.image = UIImage(named: "img_placeholder")
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShimmerListingCell", for: indexPath) as! ShimmerListingCollectionViewCell
            cell.layoutIfNeeded()
//            if (indexPath.item == 0 || indexPath.item == 1){
//                cell.containerViewTop.constant = 16
//            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isDataLoaded{
            let listingDetailVC = ListingDetailViewController()
            listingDetailVC.product = self.products[indexPath.item]
            self.navigationController?.pushViewController(listingDetailVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.item == 0 || indexPath.item == 1){
            return CGSize(width: self.newListingCollectionView.frame.width/2, height: (self.newListingCollectionView.frame.width/2) + 72 + 24)
        }else{
            return CGSize(width: self.newListingCollectionView.frame.width/2, height: (self.newListingCollectionView.frame.width/2) + 72 + 16)
        }
    }
}
