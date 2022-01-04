//
//  MyProductViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD
import AlamofireImage

struct MyProductSource{
    static let ACCOUNT = "ACCOUNT"
    static let QUOTATION = "QUOTATION"
}

class MyProductViewController: UIViewController {

    @IBOutlet var myProductTableView: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    private var products:[Product] = []
    private var disposeBag = DisposeBag()
    private let productVM = ProductVM()
    private var isDataLoaded = false
    
    var sourceVC:String = MyProductSource.ACCOUNT
    var createQuotationDelegate: CreateQuotationProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.observeViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent{
            self.disposeBag = DisposeBag()
        }
    }
    
    private func setupViews(){
        self.title = "My Product"
        self.myProductTableView.register(UINib(nibName: "MyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "MyProductCell")
        self.myProductTableView.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerMyProductCell")
    }
    
    private func setupData(){
        self.emptyStateL.isHidden = true
        self.isDataLoaded = false
        self.products.removeAll()
        
        self.myProductTableView.reloadData()
        
        productVM.getSellerProducts(sellerId: nil, paginate: 100)
    }
    
    private func observeViewModel(){
        productVM.products.bind { (products) in
            self.products = products
            self.isDataLoaded = true
            self.myProductTableView.reloadData()
            
            if (self.products.count <= 0){
                self.emptyStateL.isHidden = false
            }
        }.disposed(by: disposeBag)
        
        productVM.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
                        
            self.isDataLoaded = true
            self.emptyStateL.isHidden = false
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
}

extension MyProductViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.products.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isDataLoaded{
            if self.sourceVC == MyProductSource.ACCOUNT{
                let productDetailVC = ListingDetailViewController()
                productDetailVC.type = ProductDetailSource.MY_PRODUCT
                productDetailVC.product = self.products[indexPath.item]
                self.navigationController?.pushViewController(productDetailVC, animated: true)
            }else{
                self.createQuotationDelegate?.didProductSelected(product: self.products[indexPath.item])
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyProductCell", for: indexPath) as! MyProductTableViewCell
            cell.productNameL.text = self.products[indexPath.item].itemName
            cell.productPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: self.products[indexPath.item].price)! + "/ " + self.products[indexPath.item].unit.unitName
            if self.products[indexPath.item].images.count > 0{
                if let imageURL = URL(string: Network.ASSET_URL + self.products[indexPath.item].images[0].imageUrl){
                    cell.productImageView.af.setImage(withURL: imageURL, placeholderImage: UIImage(named: "img_placeholder"))
                }
            }else{
                cell.productImageView.image = UIImage(named: "img_placeholder")
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerMyProductCell", for: indexPath) as! ShimmerMyProductTableViewCell
            return cell
            
        }
        
    }
}
