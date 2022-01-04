//
//  LoginViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 11/01/21.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

struct LoginSourceVC {
    static let MAIN = "MAIN"
    static let ACCOUNT = "ACCOUNT"
}

class LoginViewController: UberBizViewController {

    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var signUpSellerBtn: UberBizButton!
    @IBOutlet var eyeToggleIV: UIImageView!
    @IBOutlet var underlineVs: [UIView]!
    @IBOutlet var iconIVs: [UIImageView]!
    
    @IBOutlet var dismissV: UIView!
    
    private var user:User?
    private var disposeBag = DisposeBag()
    
    var sourceVC = LoginSourceVC.MAIN
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.disposeBag = DisposeBag()
        observeViewModel()
    }

    private func setupViews(){
        self.emailTF.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        self.passwordTF.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        
        self.signUpSellerBtn.layer.borderColor = Color.OUTLINE_BUTTON_COLOR.cgColor
        self.signUpSellerBtn.layer.borderWidth = 1
        
        if self.sourceVC == LoginSourceVC.ACCOUNT{
            self.dismissV.isHidden = false
        }
    }
    
    private func observeViewModel(){
        UserVM.shared.isLoginSuccess.bind { (isSuccess) in
            UserDefaultHelper.shared.setupIsOnBoardLoaded()
            UserVM.shared.getUserDetail()
        }.disposed(by: disposeBag)
        
        UserVM.shared.user.bind { (user) in
            self.user = user
            SVProgressHUD.dismiss()
            
            guard var currentUser = self.user else {return}
            
            do {
                if let user = UserDefaultHelper.shared.getUser(){
                    currentUser.accessToken = user.accessToken
                }
                let data = try JSONEncoder().encode(currentUser)
                UserDefaultHelper.shared.setupUser(data: data)
                                
                let rootNavigationController = UINavigationController.init(rootViewController: TabBarViewController())
                rootNavigationController.modalPresentationStyle = .fullScreen
                self.present(rootNavigationController, animated: true, completion: nil)
            }catch(let error){
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            }
            
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func isValid()->Bool{
        if (self.emailTF.text == ""){
            return false
        }
        
        if (self.passwordTF.text == ""){
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
    
    @IBAction func signInAction(_ sender: Any) {
        SVProgressHUD.show()
        
        if self.isValid(){
            if self.sourceVC == LoginSourceVC.MAIN{
                UserVM.shared.login(email: emailTF.text!, password: passwordTF.text!)
            }else{
                UserVM.shared.linkAccount(email: emailTF.text!, password: passwordTF.text!)
            }
            
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
//        let rootNavigationController = UINavigationController.init(rootViewController: TabBarViewController())
//        rootNavigationController.modalPresentationStyle = .fullScreen
//        self.present(rootNavigationController, animated: true, completion: nil)
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        let forgotPasswordVC = ForgotPasswordViewController()
        forgotPasswordVC.modalPresentationStyle = .fullScreen
        self.present(forgotPasswordVC, animated: true, completion: nil)
    }
    
    
    @IBAction func signUpSellerAction(_ sender: Any) {
        let signUpSellerVC = SignUpSellerViewController()
        signUpSellerVC.sourceVC = self.sourceVC
        signUpSellerVC.modalPresentationStyle = .fullScreen
        self.present(signUpSellerVC, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate{
    
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
        case self.emailTF:
            self.passwordTF.becomeFirstResponder()
        default:
            self.passwordTF.resignFirstResponder()
        }
        return false
    }
}
