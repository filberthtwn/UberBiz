//
//  StoreReviewViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 20/02/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class StoreReviewViewController: UIViewController {

    @IBOutlet var reviewTableV: UITableView!
    
    @IBOutlet var sellerNameL: UILabel!
    @IBOutlet var ratingL: UILabel!
    @IBOutlet var storeDescL: UILabel!
    
    @IBOutlet var verifiedIV: UIImageView!
    
    private var reviews:[Review] = []
    private var isDataLoaded = false
    private var disposeBag = DisposeBag()
    
    var seller:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.setupDefaultValue()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Store Page"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.reviewTableV.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.reviewTableV.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        
        self.reviewTableV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    private func setupData(){
        if let seller = self.seller{
            ReviewVM.shared.getReview(sellerId: seller.id!, paginate: 100)
        }else{
            SVProgressHUD.showError(withStatus: "Seller is missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    private func setupDefaultValue(){
        if let seller = self.seller{
            self.sellerNameL.text = seller.storeName ?? "Unknown"
                
            if seller.isVerified == 0{
                self.verifiedIV.isHidden = true
            }else{
                self.verifiedIV.isHidden = false
            }
            
            if let rating = seller.rating{
                self.ratingL.text = String(format: "%.1f/5", rating)
            }
            
            self.storeDescL.text = seller.storeDescription ?? "No Description"
        }else{
            SVProgressHUD.showError(withStatus: "Seller missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
        
    }
    
    private func observeViewModel(){
        ReviewVM.shared.reviews.bind { (reviews) in
            self.disposeBag = DisposeBag()
            self.isDataLoaded = true
            
            self.reviews = reviews
            self.reviewTableV.reloadData()
        }.disposed(by: disposeBag)
        
        ReviewVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
}

extension StoreReviewViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.reviews.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
            
            let rate = self.reviews[indexPath.item].rate
            for x in 0..<4 {
                cell.starIVs[x].tintColor = Color.STAR_INACTIVE
            }
            for x in 0..<Int(rate) {
                cell.starIVs[x].tintColor = Color.STAR_ACTIVE
            }

            cell.ratingL.text = String(format: "%.1f/5", self.reviews[indexPath.item].rate)
            cell.customerNameL.text = self.reviews[indexPath.item].user?.storeName
            cell.reviewDescL.text = self.reviews[indexPath.item].description ?? "No Description"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
    }
}
