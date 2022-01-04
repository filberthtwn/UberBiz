//
//  CreateWithdrawViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/03/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class CreateWithdrawViewController: UIViewController {

    @IBOutlet var balanceRpContainerV: UIView!
    
    @IBOutlet var bankNameTF: UITextField!
    @IBOutlet var accountNameTF: UITextField!
    @IBOutlet var accountNumberTF: UITextField!
    @IBOutlet var amountTF: UITextField!
    @IBOutlet var messageTF: UITextField!
    
    @IBOutlet var balanceL: UILabel!
    @IBOutlet var errorMsgL: UILabel!
    @IBOutlet var messageCounterL: UILabel!
    
    private var userVM = UserVM()
    private var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupDefaultData()
        self.observeViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        self.title = "Create Withdraw"
        self.balanceRpContainerV.layer.cornerRadius = 4
        self.balanceRpContainerV.layer.borderWidth = 1
        self.balanceRpContainerV.layer.borderColor = UIColor(red: 255/255, green: 107/255, blue: 0/255, alpha: 1).cgColor
        
        self.amountTF.addTarget(self, action: #selector(didValueChanged(_:)), for: .editingChanged)
        self.messageTF.addTarget(self, action: #selector(didValueChanged(_:)), for: .editingChanged)

        self.errorMsgL.isHidden = true
    }
    
    private func setupDefaultData(){
        if let user = UserDefaultHelper.shared.getUser(){
            self.balanceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(user.storeBalance ?? 0))!
        }
    }
    
    private func observeViewModel(){
        WithdrawVM.shared.isSuccess.bind { (isSuccess) in
            self.userVM.getUserDetail()
        }.disposed(by: disposeBag)
        
        userVM.user.bind { (user) in
            do{
                if let currentUser = UserDefaultHelper.shared.getUser(){
                    var newUser = user
                    newUser.accessToken = currentUser.accessToken
                    let data = try JSONEncoder().encode(newUser)
                    UserDefaultHelper.shared.setupUser(data: data)
                    
                    SVProgressHUD.showSuccess(withStatus: "Withdraw successfull")
                    SVProgressHUD.dismiss(withDelay: Delay.SHORT)
                    self.navigationController?.popViewController(animated: true)
                }
            }catch (let error){
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            }
        }.disposed(by: disposeBag)
        
        WithdrawVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func isValid()->Bool{
        if self.bankNameTF.text! == ""{
            return false
        }
        
        if self.accountNameTF.text! == ""{
            return false
        }
        
        if self.accountNumberTF.text! == ""{
            return false
        }
        
        if self.amountTF.text! == ""{
            return false
        }
        
        return true
    }
    
    @objc private func didValueChanged(_ textField: UITextField){
        if textField == amountTF{
            if let user = UserDefaultHelper.shared.getUser(){
                let withdrawAmountStr = textField.text!.replacingOccurrences(of: "Rp", with: "").replacingOccurrences(of: ".", with: "")
                            
                if withdrawAmountStr != ""{
                    let withdrawAmount = Int(withdrawAmountStr)!
                    
                    let userBalance = user.storeBalance ?? 0
                    
                    if withdrawAmount > userBalance{
                        self.errorMsgL.isHidden = false
                    }else{
                        self.errorMsgL.isHidden = true
                    }
                    
                    textField.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: withdrawAmountStr)!
                }else{
                    self.errorMsgL.isHidden = true
                    textField.text!.removeAll()
                }
            }
        }else{
            let counter = self.messageTF.text!.count
            if counter > 100{
                self.messageTF.text!.removeLast()
            }else{
                self.messageCounterL.text = String(format: "%d/100", counter)
            }
        }
    }
    
    @IBAction func withdrawAction(_ sender: Any) {
        if self.isValid(){
            SVProgressHUD.show()
            let amount = self.amountTF.text!.replacingOccurrences(of: "Rp", with: "").replacingOccurrences(of: ".", with: "")
            WithdrawVM.shared.createWithdraw(amount: amount, bankName: self.bankNameTF.text!, bankNumber: self.accountNumberTF.text!, message: self.messageTF.text!)
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
        
    }
    
}
