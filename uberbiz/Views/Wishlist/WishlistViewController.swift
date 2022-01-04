//
//  WishlistViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

protocol WishlistProtocol {
    func didWishlistDeleted(wishlist: Wishlist)
}

class WishlistViewController: UIViewController {

    @IBOutlet var wishlistTableView: UITableView!
    @IBOutlet var wishlistEmptyStateL: UILabel!
    
    private var wishlists:[Wishlist] = []
    private var isDataLoaded = false
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.observeViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupData()
    }
    
    private func setupViews(){
        self.title = "Wishlist"
        self.wishlistTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 24, right: 0)
        self.wishlistTableView.register(UINib(nibName: "WishlistTableViewCell", bundle: nil), forCellReuseIdentifier: "WishlistTableCell")
        self.wishlistTableView.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
    }
    
    private func resetData(){
        wishlists.removeAll()
        isDataLoaded = false
        wishlistTableView.reloadData()
    }
    
    private func setupData(){
        self.wishlistEmptyStateL.isHidden = true
        WishlistVM.shared.getWishlists()
    }
    
    private func observeViewModel(){
        WishlistVM.shared.wishlists.bind { (wishlists) in
            self.wishlists = wishlists
            self.isDataLoaded = true
    
            self.wishlistTableView.reloadData()
            
            if wishlists.count == 0{
                self.wishlistEmptyStateL.isHidden = false
            }
            
        }.disposed(by: disposeBag)
        
        WishlistVM.shared.isSuccess.bind { (isSuccess) in
            SVProgressHUD.showSuccess(withStatus: "Wishlist deleted successfully")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            
            self.isDataLoaded = false
            self.wishlistTableView.reloadData()
            
            WishlistVM.shared.getWishlists()
            
        }.disposed(by: disposeBag)
        
        
        WishlistVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
                        
            self.isDataLoaded = true

//            self.listingCollectionView.reloadData()
//            self.updateCollectionViewHeight()
//
//            self.emptyStateV.isHidden = false
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.horizontalBarLeft.constant = scrollView.contentOffset.x/2
//    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let index = Int(scrollView.contentOffset.x/self.view.frame.width)
//        self.setupTabLayout(selectedIdx: index)
//    }
    
//    private func setupTabLayout(selectedIdx:Int){
//        for (index, element) in self.tabLayoutLabels.enumerated() {
//            if (index == selectedIdx){
//                element.textColor = .black
//            }else{
//                element.textColor = Color.TABBAR_INACTIVE_COLOR
//            }
//        }
//    }
    
//    @IBAction func didTabLayoutTapped(_ sender: UIButton) {
//        self.setupTabLayout(selectedIdx: sender.tag)
//        self.wishlistCollectionView.scrollToItem(at: IndexPath(item: sender.tag, section: 0), at: .left, animated: true)
//    }
}

extension WishlistViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.wishlists.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WishlistTableCell", for: indexPath) as! WishlistTableViewCell
            cell.productNameL.text = self.wishlists[indexPath.item].product!.itemName
            cell.productPriceL.text = "Rp." + CurrencyHelper.shared.formatCurrency(price: self.wishlists[indexPath.item].product!.price)!
            if let image = self.wishlists[indexPath.item].product!.images.first{
                if let imageUrl = URL(string: Network.ASSET_URL + image.imageUrl){
                    cell.listingImageView.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                }
            }
            let cityType = self.wishlists[indexPath.item].product!.warehouse?.city?.type ?? ""
            let cityName = self.wishlists[indexPath.item].product!.warehouse?.city?.cityName ?? ""
            cell.productCityL.text = String(format: "%@ %@", cityType, cityName)
            cell.wishlist = self.wishlists[indexPath.item]
            cell.wishlistProtocol = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isDataLoaded{
            let productDetailVC = ListingDetailViewController()
            var product = self.wishlists[indexPath.item].product
            product!.isWishlisted = true            
            productDetailVC.product = product
            self.navigationController?.pushViewController(productDetailVC, animated: true)
        }
    }

}

extension WishlistViewController: WishlistProtocol{
    func didWishlistDeleted(wishlist: Wishlist) {
        if let product = wishlist.product{
            SVProgressHUD.show()
            WishlistVM.shared.deleteWishlist(product: product)
        }else{
            SVProgressHUD.showError(withStatus: "Product is missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
        
    }
}

