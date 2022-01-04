//
//  CategoryListViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

class CategoryListViewController: UIViewController {

    @IBOutlet var categoryTableView: UITableView!
    @IBOutlet var subCategoryCollectionView: UICollectionView!
    
    private var categories:[Category] = []
    private var subCategories:[SubCategory] = []
    
    private var disposeBag = DisposeBag()
    private var isViewReady = false
    
    private var isCategoryDataLoaded = false
    private var isSubCategoryDataLoaded = false
    
    var selectedCategory:Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Categories"
        self.categoryTableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        self.categoryTableView.register(UINib(nibName: "ShimmerCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCategoryCell")
        self.categoryTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        self.subCategoryCollectionView.register(UINib(nibName: "SubCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SubCategoryCell")
        self.subCategoryCollectionView.register(UINib(nibName: "ShimmerSubCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShimmerSubCategoryCell")
        self.subCategoryCollectionView.contentInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
    }
    
    private func setupData(){
        CategoryVM.shared.getCategories()
    }
    
    private func setupSubCategoryData(){
        if let category = self.selectedCategory{
            CategoryVM.shared.getSubCategories(categoryId: category.id)
        }
    }
    
    private func observeViewModel(){
        CategoryVM.shared.categories.bind { (categories) in
            self.categories = categories
            self.isCategoryDataLoaded = true
            if let category = self.categories.first{
                if self.selectedCategory == nil{
                    self.selectedCategory = category
                }
                self.setupSubCategoryData()
            }
            self.setupSubCategoryData()
            self.categoryTableView.reloadData()
        }.disposed(by: disposeBag)
        
        CategoryVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
        
        CategoryVM.shared.subCategories.bind { (subCategories) in
            self.subCategories = subCategories
            self.isSubCategoryDataLoaded = true
            self.subCategoryCollectionView.reloadData()
        }.disposed(by: disposeBag)
    }
    
}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isCategoryDataLoaded{
            return self.categories.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.isCategoryDataLoaded){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
            cell.categoryNameL.text = self.categories[indexPath.item].categoryName
            
            if (self.categories[indexPath.item].id == self.selectedCategory!.id){
                cell.selectItem()
            }else{
                cell.deselectItem()
            }
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCategoryCell", for: indexPath) as! ShimmerCategoryTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isCategoryDataLoaded{
            self.selectedCategory = self.categories[indexPath.item]
            self.setupSubCategoryData()
            self.categoryTableView.reloadData()
            
            self.isSubCategoryDataLoaded = false
            self.subCategoryCollectionView.reloadData()
        }
    }
}

extension CategoryListViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.subCategoryCollectionView.frame.width-24)/2, height: ((self.subCategoryCollectionView.frame.width-24)/2) + (17 + 8))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isSubCategoryDataLoaded{
            let listingListVC = ListingListViewController()
            listingListVC.subcategory = self.subCategories[indexPath.item]
            listingListVC.searchQuery = self.subCategories[indexPath.item].subCategoryName
            self.navigationController?.pushViewController(listingListVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isSubCategoryDataLoaded{
            return self.subCategories.count
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isSubCategoryDataLoaded{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCollectionViewCell
            cell.categoryNameL.text = self.subCategories[indexPath.item].subCategoryName
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShimmerSubCategoryCell", for: indexPath) as! ShimmerSubCategoryCollectionViewCell
            return cell
        }
    }
}
