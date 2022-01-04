//
//  SignUpSellerViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 26/01/21.
//

import UIKit
import SVProgressHUD
import RxCocoa
import RxSwift

class SignUpSellerViewController: UberBizViewController {

    
    @IBOutlet var storeNameTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    
    @IBOutlet var underlineVs: [UIView]!
    
    @IBOutlet var iconIVs: [UIImageView]!
    @IBOutlet var eyeToggleIV: UIImageView!
    
    @IBOutlet var signInBuyerBtn: UberBizButton!
    
    private var user:User?
    private var disposeBag = DisposeBag()
    var sourceVC: String = LoginSourceVC.MAIN

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.observeViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        self.storeNameTF.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        self.emailTF.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        self.passwordTF.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        
        self.signInBuyerBtn.layer.borderColor = Color.OUTLINE_BUTTON_COLOR.cgColor
        self.signInBuyerBtn.layer.borderWidth = 1
    }
    
    private func observeViewModel(){
        
        UserVM.shared.isRegisterSuccess.bind { (isSuccess) in
            if isSuccess{
                if self.sourceVC == LoginSourceVC.MAIN{
                    UserVM.shared.login(email: self.emailTF.text!, password: self.passwordTF.text!)
                }else{
                    UserVM.shared.linkAccount(email: self.emailTF.text!, password: self.passwordTF.text!)
                }
            }
        }.disposed(by: disposeBag)
        
        UserVM.shared.user.bind { (user) in
            SVProgressHUD.dismiss()
            self.user = user
        }.disposed(by: disposeBag)
        
        UserVM.shared.isLoginSuccess.bind { (isSuccess) in
            UserDefaultHelper.shared.setupIsOnBoardLoaded()
            UserVM.shared.getUserDetail()
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.asObservable().bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func isValid()->Bool{
        if self.storeNameTF.text == "" {
            return false
        }
        
        if self.emailTF.text == ""{
            return false
        }
        
        if self.passwordTF.text == ""{
            return false
        }
        
        return true
    }
    
    @IBAction func passwordToggleAction(_ sender: Any) {
        if self.passwordTF.isSecureTextEntry{
            self.eyeToggleIV.image = UIImage(named: "eye-slash-icon")
        }else{
            self.eyeToggleIV.image = UIImage(named: "eye-icon")
        }
        self.passwordTF.isSecureTextEntry = !self.passwordTF.isSecureTextEntry
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        SVProgressHUD.show()
        if self.isValid(){
            UserVM.shared.registerSeller(storeName: self.storeNameTF.text!, email: self.emailTF.text!, password: self.passwordTF.text!)
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SignUpSellerViewController: UITextFieldDelegate{
    
    @objc func textFieldValueChanged(_ textField: UITextField){
        if (textField.text! != ""){
            self.iconIVs[textField.tag].tintColor = Color.PRIMARY_COLOR
            if (textField == self.passwordTF){
                self.eyeToggleIV.tintColor = Color.PRIMARY_COLOR
            }
            self.underlineVs[textField.tag].backgroundColor = Color.PRIMARY_COLOR
        }else{
            self.iconIVs[textField.tag].tintColor = Color.ICON_COLOR
            if (textField == self.passwordTF){
                self.eyeToggleIV.tintColor = Color.ICON_COLOR
            }
            self.underlineVs[textField.tag].backgroundColor = Color.UNDERLINE_COLOR
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.storeNameTF:
            self.emailTF.becomeFirstResponder()
        case self.emailTF:
            self.passwordTF.becomeFirstResponder()
        default:
            self.passwordTF.resignFirstResponder()
        }
        return false
    }
}

