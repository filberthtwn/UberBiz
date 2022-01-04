//
//  ForgotPasswordViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 26/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class ForgotPasswordViewController: UberBizViewController {

    @IBOutlet var emailIV: UIImageView!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var lineV: UIView!
    
    private var disposeBag:DisposeBag = DisposeBag()
    
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
        self.emailTF.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
    }
    
    private func observeViewModel(){
        UserVM.shared.isSuccess.bind { (isSuccess) in
            SVProgressHUD.dismiss()
            
            let forgotPasswordSuccessVC = ForgotPasswordSuccessViewController()
            forgotPasswordSuccessVC.modalPresentationStyle = .fullScreen
            self.present(forgotPasswordSuccessVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
                        
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func sendRequest(){
        if self.isValid(){
            SVProgressHUD.show()
            UserVM.shared.forgotPassword(email: self.emailTF.text!)
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
    
    private func isValid()->Bool{
        if self.emailTF.text! == ""{
            return false
        }
        return true
    }

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendEmailConfirmationAction(_ sender: Any) {
        self.sendRequest()
    }

}

extension ForgotPasswordViewController: UITextFieldDelegate{
    
    @objc func textFieldValueChanged(_ textField: UITextField){
        if (textField.text! != ""){
            self.emailIV.tintColor = Color.PRIMARY_COLOR
            self.lineV.backgroundColor = Color.UNDERLINE_COLOR
        }else{
            self.emailIV.tintColor = Color.ICON_COLOR
            self.lineV.backgroundColor = Color.UNDERLINE_COLOR
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendRequest()
        
        return false
    }
}
