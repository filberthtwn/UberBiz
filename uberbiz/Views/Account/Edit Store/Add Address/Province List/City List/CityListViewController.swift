//
//  CityListViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class CityListViewController: UIViewController {
    
    @IBOutlet var cityTableView: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    private var cities:[City] = []
    private var isDataLoaded = false
    private var disposeBag = DisposeBag()
    
    var selectedProvince: Province?
    var delegate: AddAddressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Choose City"
        self.cityTableView.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.cityTableView.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "TextCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupData(){
        if let province = self.selectedProvince{
            UserVM.shared.getCities(province: province)
        }else{
            self.emptyStateL.isHidden = false
            self.isDataLoaded = true
        }
    }
    
    private func observeViewModel(){
        UserVM.shared.cities.bind { (cities) in
            self.disposeBag = DisposeBag()
            self.cities = cities
                        
            self.isDataLoaded = true
            self.cityTableView.reloadData()
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
}

extension CityListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.cities.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isDataLoaded{
            self.delegate?.didSelectCity(city: self.cities[indexPath.item])
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            cell.textL.text = self.cities[indexPath.item].type + " " + self.cities[indexPath.item].cityName
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
    }
}
