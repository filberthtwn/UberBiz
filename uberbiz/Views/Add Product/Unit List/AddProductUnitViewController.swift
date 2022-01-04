//
//  AddProductUnitViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

struct UnitVCSource {
    static let CREATE_PRODUCT = "CREATE_PRODUCT"
    static let REQUEST = "REQUST"
}

class AddProductUnitViewController: UIViewController {

    @IBOutlet var unitTableView: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    var productFormDelegate: AddProductDelegate?
    var createRequestDelegate: CreateRequestDelegate?
    var type:String = UnitVCSource.CREATE_PRODUCT
    
    private var units:[Unit] = []
    private var isDataLoaded = false
    private var disposeBag:DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Choose Unit"
        self.unitTableView.register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "TextCell")
        self.unitTableView.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
    }
    
    private func setupData(){
        self.emptyStateL.isHidden = true
        UnitVM.shared.getUnits()
    }
    
    private func observeViewModel(){
        UnitVM.shared.units.bind { (units) in
            self.units = units
            self.isDataLoaded = true
            self.unitTableView.reloadData()

            if self.units.count <= 0{
                self.emptyStateL.isHidden = false
            }

        }.disposed(by: disposeBag)

        UnitVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}

            self.isDataLoaded = true
            self.emptyStateL.isHidden = false

            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
}

extension AddProductUnitViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.units.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            cell.textL.text = self.units[indexPath.item].unitName
           
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath) as! ShimmerMyProductTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isDataLoaded{
            if self.type == UnitVCSource.CREATE_PRODUCT{
                productFormDelegate?.didSelectUnit(unit: self.units[indexPath.item])
            }else{
                createRequestDelegate?.didSelectUnit(unit: self.units[indexPath.item])
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}
