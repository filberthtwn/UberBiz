//
//  AddProductCategoryListViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

struct CategoryVCSource {
    static let CREATE_PRODUCT = "CREATE_PRODUCT"
    static let REQUEST = "REQUST"
}

class AddProductCategoryListViewController: UIViewController {

    @IBOutlet var categoryTableView: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    private var categories:[Category] = []
    private var isDataLoaded = false
    private var disposeBag = DisposeBag()
    
    var productFormDelegate: AddProductDelegate?
    var createRequestDelegate: CreateRequestDelegate?
    var type:String = CategoryVCSource.CREATE_PRODUCT
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Choose Category"
        
        self.categoryTableView.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "TextCell")
        self.categoryTableView.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
    }
    
    private func setupData(){
        self.emptyStateL.isHidden = true
        CategoryVM.shared.getCategories()
    }
    
    private func observeViewModel(){
        CategoryVM.shared.categories.bind { (categories) in
            self.categories = categories
            self.isDataLoaded = true
            self.categoryTableView.reloadData()
            
            if self.categories.count <= 0{
                self.emptyStateL.isHidden = false
            }
            
        }.disposed(by: disposeBag)
        
        CategoryVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
                        
            self.isDataLoaded = true
            self.emptyStateL.isHidden = false

            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
}

extension AddProductCategoryListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.categories.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            cell.textL.text = self.categories[indexPath.item].categoryName
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath) as! ShimmerMyProductTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subCategoryVC = AddProductSubCategoryViewController()
        subCategoryVC.type = self.type
        subCategoryVC.productFormDelegate = productFormDelegate
        subCategoryVC.createRequestDelegate = createRequestDelegate
        subCategoryVC.category = self.categories[indexPath.item]
        self.navigationController?.pushViewController(subCategoryVC, animated: true)
    }
    
    
}
