//
//  SearchListingViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/03/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class SearchListingViewController: UberBizViewController {
    
    @IBOutlet var productCollectionV: UICollectionView!
    @IBOutlet var searchQueryL: UILabel!
    @IBOutlet var emptyStateL: UILabel!
    
    private var products: [Product] = []
    private var isDataLoaded: Bool = false
    private var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.searchQueryL.text = String(format: "Search result \"%@\"", self.searchQuery!)
        self.productCollectionV.register(UINib(nibName: "ListingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ListingCell")
        self.productCollectionV.register(UINib(nibName: "ShimmerListingCollectionViewCell", bundle: nil),   forCellWithReuseIdentifier: "ShimmerCell")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.disposeBag = DisposeBag()
    }
    
    private func setupData(){
        ProductVM.shared.getBuyerProducts(sellerId: nil, subCategoryId: nil, productName: self.searchQuery, paginate: 15)
    }
    
    private func observeViewModel(){
        ProductVM.shared.products.bind { (products) in
            self.products = products
            self.isDataLoaded = true
                            
            self.productCollectionV.reloadData()
            
            if (self.products.count <= 0){
                self.emptyStateL.isHidden = false
            }
            
        }.disposed(by: disposeBag)
        
        ProductVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            self.disposeBag = DisposeBag()
                        
            self.isDataLoaded = true

            self.productCollectionV.reloadData()

            self.emptyStateL.isHidden = false
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    override func didBackAction(_ sender: UITapGestureRecognizer) {
        for viewController in self.navigationController!.viewControllers as Array {
            print(viewController)
            if viewController.isKind(of: TabBarViewController.self) {
                self.navigationController!.popToViewController(viewController, animated: true)
                break
            }
        }
    }
    
}

extension SearchListingViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.products.count
        }else{
            return 10
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isDataLoaded{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingCell", for: indexPath) as! ListingCollectionViewCell
            if (indexPath.item == 0 || indexPath.item == 1){
                cell.containerViewTop.constant = 16
            }
            
            cell.productNameL.text = self.products[indexPath.item].itemName
            if let price = CurrencyHelper.shared.formatCurrency(price: self.products[indexPath.item].price){
                cell.priceL.text = "Rp. " + price
            }
            cell.cityNameL.text = self.products[indexPath.item].warehouse!.city!.type + " " + self.products[indexPath.item].warehouse!.city!.cityName
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShimmerCell", for: indexPath) as! ShimmerListingCollectionViewCell
            if (indexPath.item == 0 || indexPath.item == 1){
                cell.containerViewTop.constant = 16
            }
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
            return CGSize(width: self.productCollectionV.frame.width/2, height: (self.productCollectionV.frame.width/2) + 72 + 24)
        }else{
            return CGSize(width: self.productCollectionV.frame.width/2, height: (self.productCollectionV.frame.width/2) + 72 + 16)
        }
    }
}
