//
//  HomeViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/01/21.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD
import Shimmer
import Alamofire
import AlamofireImage

class HomeViewController: UIViewController {
    @IBOutlet var shimmerContainerV: UberBizShimmerView!
    @IBOutlet var shimmerContentV: UIStackView!
    
    @IBOutlet var bannerShimmerContainerV: UberBizShimmerView!
    @IBOutlet var bannerShimmerContentV: UIView!
    
    @IBOutlet var categoryImageShimmerV: [UIView]!
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var emptyStateV: UIView!
    
    @IBOutlet var bannerCV: UICollectionView!
    @IBOutlet var listingCollectionView: UICollectionView!
    @IBOutlet var listingCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var categoryV: UIView!
    @IBOutlet var categoryImageView: [UIImageView]!
    @IBOutlet var categoryL: [UILabel]!
    
    private var banners:[Banner] = []
    private var products:[Product] = []
    private var categories:[Category] = []

    private var isDataLoaded = false
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupData()
        self.observeViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        self.bannerCV.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCell")
        self.listingCollectionView.register(UINib(nibName: "ListingCollectionViewCell", bundle: nil),   forCellWithReuseIdentifier: "NewListingCell")
        self.listingCollectionView.register(UINib(nibName: "ShimmerListingCollectionViewCell", bundle: nil),   forCellWithReuseIdentifier: "ShimmerListingCell")
        self.shadowView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.shadowView.layer.shadowOpacity = 1
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.shadowView.layer.shadowRadius = 6
        
        self.shimmerContainerV.contentView = self.shimmerContentV
        
        self.bannerShimmerContainerV.contentView = self.bannerShimmerContentV
    }
    
    private func setupData(){
        
        self.isDataLoaded = false
        self.emptyStateV.isHidden = true

        self.bannerShimmerContainerV.isHidden = false
        self.banners.removeAll()
        self.bannerCV.reloadData()

        self.categories.removeAll()
        self.shimmerContainerV.isHidden = false
        self.categoryV.isHidden = true
        
        self.products.removeAll()
        self.listingCollectionView.reloadData()
                
        UserVM.shared.getBanners()
        CategoryVM.shared.getCategories()
        ProductVM.shared.getBuyerProducts(sellerId: nil, subCategoryId: nil, productName: nil, paginate: 100)
    }
    
    private func observeViewModel(){
        UserVM.shared.banners.bind { (banners) in
            self.bannerShimmerContainerV.isHidden = true
            self.banners = banners
            self.bannerCV.reloadData()
        }.disposed(by: disposeBag)
        
        CategoryVM.shared.categories.bind { (categories) in
            self.categories = categories
            self.shimmerContainerV.isHidden = true
            self.categoryV.isHidden = false
            
            self.isDataLoaded = true
            
            for (idx, category) in self.categories.enumerated(){
                if (idx < self.categoryL.count){
                    if let imageUrlString = category.categoryImageUrl{
                        if let imageUrl = URL(string: imageUrlString){
                            self.categoryImageView[idx].af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                        }
                    }else{
                        self.categoryImageView[idx].image = UIImage(named: "img_placeholder")
                    }
                    self.categoryL[idx].text = category.categoryName
                }else{
                    break
                }
            }
                        
        }.disposed(by: disposeBag)
        
        ProductVM.shared.products.bind { (products) in
            self.products = products
            self.isDataLoaded = true
                                        
            self.listingCollectionView.reloadData()
            self.updateCollectionViewHeight()
            
            if (self.products.count <= 0){
                self.emptyStateV.isHidden = false
            }else{
                self.emptyStateV.isHidden = true
            }
            
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            self.disposeBag = DisposeBag()
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
        
        CategoryVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            self.disposeBag = DisposeBag()
                        
            self.isDataLoaded = true

            self.listingCollectionView.reloadData()
            self.updateCollectionViewHeight()
            
            self.view.layoutIfNeeded()
            self.listingCollectionView.layoutIfNeeded()

            self.emptyStateV.isHidden = false
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
        
        ProductVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            self.disposeBag = DisposeBag()
                        
            self.isDataLoaded = true

            self.listingCollectionView.reloadData()
            self.updateCollectionViewHeight()

            self.emptyStateV.isHidden = false
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        if !self.isDataLoaded{
            let cellHeight = ((self.listingCollectionView.frame.width/2)+48+16)
            self.listingCollectionViewHeight.constant = cellHeight * 3
        }
        
        for imageView in self.categoryImageView {
            self.view.layoutIfNeeded()
            imageView.layer.cornerRadius = imageView.frame.width/2
        }
        
        for categoryImageShimmerV in self.categoryImageShimmerV {
            self.view.layoutIfNeeded()
            categoryImageShimmerV.layer.cornerRadius = categoryImageShimmerV.frame.width/2
        }
    }
    
    private func updateCollectionViewHeight(){
        let cellHeight = ((self.listingCollectionView.frame.width/2) + 72 + 16)
        self.listingCollectionViewHeight.constant = cellHeight * CGFloat(Double(self.products.count)/2).rounded(.up)
        self.view.layoutIfNeeded()
    }
    
    @IBAction func categoryAction(_ sender: UIButton) {
        let categoryListVC = CategoryListViewController()
        categoryListVC.selectedCategory = self.categories[sender.tag]
        self.navigationController?.pushViewController(categoryListVC, animated: true)
    }
    
    @IBAction func seeAllCategoryAction(_ sender: Any) {
        self.navigationController?.pushViewController(CategoryListViewController(), animated: true)
    }
    
    @IBAction func seeAllAction(_ sender: Any) {
        self.navigationController?.pushViewController(NewListingViewController(), animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.bannerCV{
            return CGSize(width: self.bannerCV.frame.width, height: self.bannerCV.frame.height)
        }else{
            if self.isDataLoaded{
                return CGSize(width: self.listingCollectionView.frame.width/2, height: (self.listingCollectionView.frame.width/2) + 72 + 16)
            }else{
                return CGSize(width: self.listingCollectionView.frame.width/2, height: (self.listingCollectionView.frame.width/2)+48+16)
            }
        }
    }
}

extension HomeViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.bannerCV{
            return self.banners.count
        }else{
            if (self.isDataLoaded){
                print("PRODUCTS: \(self.products.count)")
                return self.products.count
            }else{
                return 6
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.bannerCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as! BannerCollectionViewCell
            if let imageUrl = URL(string: Network.ASSET_URL + self.banners[indexPath.item].imageUrl){
                cell.bannerIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
            }
            return cell
        }else{
            if self.isDataLoaded{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewListingCell", for: indexPath) as! ListingCollectionViewCell
//                cell.layoutIfNeeded()
                
                cell.productNameL.text = self.products[indexPath.item].itemName
                if let price = CurrencyHelper.shared.formatCurrency(price: self.products[indexPath.item].price){
                    cell.priceL.text = "Rp. " + price
                }
                
                if let warehouse = self.products[indexPath.item].warehouse{
                    cell.cityNameL.text = warehouse.city!.type + " " + self.products[indexPath.item].warehouse!.city!.cityName
                }else{
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
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.listingCollectionView{
            if self.isDataLoaded{
                let listingDetailVC = ListingDetailViewController()
                listingDetailVC.product = self.products[indexPath.item]
                self.navigationController?.pushViewController(listingDetailVC, animated: true)
            }
        }
    }
}

