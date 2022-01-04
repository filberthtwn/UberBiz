//
//  ManualPaymentViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 16/03/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class ManualPaymentViewController: UberBizViewController {

    @IBOutlet var accountNumberL: UILabel!
    @IBOutlet var fileNameL: UILabel!
    @IBOutlet var totalPaymentL: UILabel!
    
    @IBOutlet var uploadV: UberBizDashedView!
    @IBOutlet var uploadSV: UIStackView!
    @IBOutlet var receiptPreviewSV: UIStackView!
    @IBOutlet var receiptIV: UIImageView!
    
    @IBOutlet var deleteReceiptV: UIView!
    
    @IBOutlet var sendPaymentBtn: UberBizButton!
    
    var order: Order?
    var totalPayment:Int = 0
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.observeViewModel()
    }
    
    private func setupViews(){
        self.title = "Completing Payment"
        
        // Mute send payment button for default
        self.sendPaymentBtn.mute()
        
        self.deleteReceiptV.layer.cornerRadius = self.deleteReceiptV.frame.height/2
        self.receiptPreviewSV.isHidden = true
        self.receiptIV.layer.cornerRadius = 6
        
        self.setupDefaultValue()
    }
    
    private func setupDefaultValue(){
        self.totalPaymentL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(self.totalPayment))!
    }
    
    private func observeViewModel(){
        OrderVM.shared.paymentReceiptUrl.bind { (paymentReceiptUrl) in
            if let order = self.order{
                SVProgressHUD.dismiss()
                OrderVM.shared.sendPayementReceipt(imageUrl: paymentReceiptUrl, order: order)
            }else{
                SVProgressHUD.showError(withStatus: "Order is missing")
                SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            }
        }.disposed(by: disposeBag)
        
        OrderVM.shared.isSuccess.bind { (isConnectSuccess) in
            self.disposeBag = DisposeBag()
            
            SVProgressHUD.showSuccess(withStatus: "Payment sent successfully")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
                        
            let orderDetailVC = OrderDetailViewController()
            orderDetailVC.sourceVC = .PAYMENT
            self.navigationController?.pushViewController(orderDetailVC, animated: true)
        }.disposed(by: disposeBag)
        
        OrderVM.shared.errorMsg.bind { (errorMsg) in
            self.disposeBag = DisposeBag()
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    override func didImagePicked(image: UIImage, fileName: String) {
        self.uploadSV.isHidden = true
        self.receiptPreviewSV.isHidden = false
        self.receiptIV.image = image
        
        self.fileNameL.text = fileName
        
        // Unmute send payment button after image selected
        self.sendPaymentBtn.unmutePrimary()
    }
    
    @IBAction func copyAction(_ sender: Any) {
        UIPasteboard.general.string = self.accountNumberL.text!
        SVProgressHUD.showSuccess(withStatus: "Copied to clipboard!")
        SVProgressHUD.dismiss(withDelay: Delay.SHORT)
    }
    
    @IBAction func deleteImageAction(_ sender: Any) {
        self.uploadSV.isHidden = false
        self.receiptPreviewSV.isHidden = true
        self.receiptIV.image = nil
        
        self.fileNameL.text = "No image picked"
        
        // Mute send payment button when image deleted
        self.sendPaymentBtn.mute()
    }
    
    @IBAction func uploadAction(_ sender: Any) {
        self.showPickerModal()
    }
    
    @IBAction func sendPaymentAction(_ sender: Any) {
        if let image = self.receiptIV.image{
            SVProgressHUD.show()
            if let order = self.order{
                OrderVM.shared.checkoutOrder(order: order, paymentCode: "BCA", paymentCategory: "Virtual Account", isInsurance: true)
            }
//            OrderVM.shared.uploadPayementReceipt(image: image)
        }
    }
}
