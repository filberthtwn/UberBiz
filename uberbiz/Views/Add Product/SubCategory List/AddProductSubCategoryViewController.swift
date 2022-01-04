//
//  AddProductSubCategoryViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 31/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class AddProductSubCategoryViewController: UIViewController {

    @IBOutlet var subCategoryTV: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    var productFormDelegate: AddProductDelegate?
    var createRequestDelegate: CreateRequestDelegate?
    var category:Category?
    private var subCategories:[SubCategory] = []
    private var isDataLoaded = false
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    var type:String = CategoryVCSource.CREATE_PRODUCT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Choose SubCategory"
        self.subCategoryTV.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "SubcategoryCell")
        self.subCategoryTV.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
    }
    
    private func setupData(){
        guard let category = self.category else {return}
        self.emptyStateL.isHidden = true
        CategoryVM.shared.getSubCategories(categoryId: category.id)
    }
    
    private func observeViewModel(){
        CategoryVM.shared.subCategories.bind { (subCategories) in
            self.subCategories = subCategories
            self.isDataLoaded = true
            self.subCategoryTV.reloadData()
            
            if self.subCategories.count <= 0{
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

extension AddProductSubCategoryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.subCategories.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubcategoryCell", for: indexPath) as! TextTableViewCell
        cell.textL.text = self.subCategories[indexPath.item].subCategoryName
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath) as! ShimmerMyProductTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for vc in self.navigationController!.viewControllers as Array {
            if self.type == CategoryVCSource.CREATE_PRODUCT{
                productFormDelegate?.didSelectCategory(subCategory: self.subCategories[indexPath.item])
                if vc.isKind(of: AddProductViewController.self) {
                    self.navigationController!.popToViewController(vc, animated: true)
                    break
                }
            }else{
                createRequestDelegate?.didSelectSubCategory(subCategory: self.subCategories[indexPath.item])
                if vc.isKind(of: CreateRequestViewController.self) {
                    self.navigationController!.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    
    
}
