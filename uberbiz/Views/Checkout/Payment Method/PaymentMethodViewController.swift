//
//  PaymentMethodViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 11/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class PaymentMethodViewController: UIViewController {

    @IBOutlet var insuranceChecklistView: UIView!
    
    private var paymentMethods:[PaymentMethod] = []
    private var disposeBag: DisposeBag = DisposeBag()

    var delegate: CheckoutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Choose Payment Method"
        self.insuranceChecklistView.layer.cornerRadius = self.insuranceChecklistView.frame.height/2
    }
    
    private func setupData(){
        OrderVM.shared.getPaymentMethods()
    }
    
    private func observeViewModel(){
        OrderVM.shared.paymentMethods.bind { (paymentMethods) in
            self.disposeBag = DisposeBag()
            self.paymentMethods = paymentMethods
            
            
            print(self.paymentMethods)
        }.disposed(by: disposeBag)
        
        OrderVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            self.disposeBag = DisposeBag()
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.delegate?.didPaymentMethodSelected()
        self.navigationController?.popViewController(animated: true)
    }
    
}
