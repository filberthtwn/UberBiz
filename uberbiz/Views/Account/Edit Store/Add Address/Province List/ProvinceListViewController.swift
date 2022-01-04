//
//  ProvinceListViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class ProvinceListViewController: UIViewController {

    @IBOutlet var provinceTableView: UITableView!
    
    private var provinces:[Province] = []
    private var isDataLoaded = false
    private var disposeBag = DisposeBag()
    
    var delegate: AddAddressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Choose Province"
        self.provinceTableView.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.provinceTableView.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "TextCell")
    }
    
    private func setupData(){
        UserVM.shared.getProvinces()
    }
    
    private func observeViewModel(){
        UserVM.shared.provinces.bind { (provinces) in
            self.disposeBag = DisposeBag()
            self.provinces = provinces
                        
            self.isDataLoaded = true
            self.provinceTableView.reloadData()
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
}

extension ProvinceListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.provinces.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isDataLoaded{
            self.delegate?.didSelectProvince(province: self.provinces[indexPath.item])
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            cell.textL.text = self.provinces[indexPath.item].provinceName
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
    }
}
