//
//  CompanyTargetListViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/02/21.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD
import SwiftyJSON

protocol CompanyTargetProtocol {
    func didSelectAll()
    func didSelectCompany(user:User)
}

class CompanyTargetListViewController: UIViewController {

    @IBOutlet var searchTF: UITextField!
    
    @IBOutlet var companyCV: UICollectionView!
    
    @IBOutlet var broadcastBtn: UIButton!
    
    @IBOutlet var companyTotalL: UILabel!
    
    private var isDataLoaded:Bool = false
    private var selectedCompanies: [User] = []
    
    private var users:[User] = []
    private var broadcastCounter = 0
    private var disposeBag:DisposeBag = DisposeBag()
    
    var requestQuotation: RequestQuotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData(companyName: nil)
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Choose Company"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.companyCV.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.companyCV.register(UINib(nibName: "ShimmerListingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShimmerCell")
        self.companyCV.register(UINib(nibName: "AllCompanyTargetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SelectAllCell")
        self.companyCV.register(UINib(nibName: "CompanyTargetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CompanyCell")
        self.companyCV.collectionViewLayout = LeftAlignedFlowLayout()

        self.broadcastBtn.layer.cornerRadius = 6
        
        self.searchTF.addTarget(self, action: #selector(didValueChange(_:)), for: .editingChanged)
    }   
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    private func setupData(companyName:String?){
        if let city = self.requestQuotation?.deliveryAddress?.city{
            if let subCategory = self.requestQuotation?.subcategory{
                UserVM.shared.getAllStore(companyName: companyName, subCategory: subCategory, city: city)
            }else{
                SVProgressHUD.showError(withStatus: "Province is missing")
                SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            }
        }else{
            SVProgressHUD.showError(withStatus: "City is missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
        
    }
    
    private func observeViewModel(){
        UserVM.shared.users.bind { (users) in
            self.isDataLoaded = true
            self.users = users
            self.selectedCompanies = self.users
            self.companyCV.reloadData()
            
            self.companyTotalL.text = String(self.selectedCompanies.count) + " company selected"
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}

            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)

        AddressVM.shared.address.bind { (address) in
            if let requestQuotation = self.requestQuotation{
                var requestQuotation = requestQuotation
                requestQuotation.deliveryAddress = address
                RequestVM.shared.createRequest(requestQuotation: requestQuotation, selectedSellers: self.selectedCompanies)
            }
        }.disposed(by: disposeBag)
        
        RequestVM.shared.requestQuotation.bind { (requestQuotation) in
            self.requestQuotation = requestQuotation
            
            SVProgressHUD.showSuccess(withStatus: "Request broadcast success")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            
            for vc in self.navigationController!.viewControllers as Array {
                if vc.isKind(of: TabBarViewController.self) {
                    TabBarItem.sourceVC = TabBarSource.REQUEST
                    self.navigationController!.popToViewController(vc, animated: true)
                    break
                }
            }
        }.disposed(by: disposeBag)
        
        RequestVM.shared.errorMsg.bind{ (errMsg) in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    @objc private func didValueChange(_ textField:UITextField){
        self.users.removeAll()
        self.isDataLoaded = false
        self.companyCV.reloadData()
        
        self.setupData(companyName: textField.text)
    }
    
    @IBAction func broadcastAction(_ sender: Any) {
        if let requestQuotation = self.requestQuotation{
            SVProgressHUD.show()
            AddressVM.shared.createAddress(address: requestQuotation.deliveryAddress!)
        }else{
            SVProgressHUD.showError(withStatus: "Request quotation missing")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
}

extension CompanyTargetListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.users.count + 1
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.isDataLoaded{
            if indexPath.item == 0{
                return CGSize(width: (self.companyCV.frame.width) - 16, height: 66)
            }else{
                return CGSize(width: (self.companyCV.frame.width/2) - 8, height: (((self.companyCV.frame.width/2)-8) + 50))
            }
        }else{
            return CGSize(width: (self.companyCV.frame.width/2) - 16, height: (self.companyCV.frame.width/2) - 16 + 48 + 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.isDataLoaded{
            if indexPath.item == 0{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectAllCell", for: indexPath) as! AllCompanyTargetCollectionViewCell
                cell.delegate = self
                
                if self.selectedCompanies.count == self.users.count{
                    cell.isSelect = true
                }else{
                    cell.isSelect = false
                }
                
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyCell", for: indexPath) as! CompanyTargetCollectionViewCell
                cell.delegate = self
                cell.user = self.users[indexPath.item-1]
                cell.storeNameL.text = self.users[indexPath.item-1].storeName
                if let imageUrlString = self.users[indexPath.item-1].storeImageUrl{
                    if let imageUrl = URL(string: Network.ASSET_URL + imageUrlString){
                        cell.storeIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                    }
                }
                
                if self.selectedCompanies.contains(where: {$0.id == self.users[indexPath.item-1].id}){
                    cell.isSelect = true
                }else{
                    cell.isSelect = false
                }
                
                return cell
            }
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
        
    }
}

extension CompanyTargetListViewController: CompanyTargetProtocol{
    func didSelectAll() {
        if self.selectedCompanies.count == self.users.count{
            self.selectedCompanies.removeAll()
        }else{
            self.selectedCompanies = self.users
        }
        self.companyCV.reloadData()
        self.companyTotalL.text = String(self.selectedCompanies.count) + " company selected"
    }
    
    func didSelectCompany(user:User) {
        if self.selectedCompanies.contains(where: {$0.id == user.id}){
            self.selectedCompanies.removeAll(where: {$0.id == user.id})
        }else{
            self.selectedCompanies.append(user)
        }
        self.companyCV.reloadData()
        self.companyTotalL.text = String(self.selectedCompanies.count) + " company selected"
    }
}
