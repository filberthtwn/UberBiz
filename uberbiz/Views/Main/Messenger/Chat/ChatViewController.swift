//
//  ChatViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 03/02/21.
//

import UIKit
import SVProgressHUD
import RxSwift
import RxCocoa
import SwiftyJSON
import Alamofire
import AlamofireImage
import IQKeyboardManagerSwift

struct ChatItem {
    var type:String = ChatItemType.TEXT
}

struct ChatItemType {
    static let TEXT = "TEXT"
    static let IMAGE = "IMAGE"
    static let QUOTATION = "QUOTATION"
    static let REQUEST = "REQUEST"
}

protocol ChatDelegate{
    func didSelectImage(index:Int)
    func didSelectQuotation(index:Int)
    func didSelectRequestQuotation(index: Int?)
}

class ChatViewController: UIViewController {
    
    @IBOutlet var chatTableV: UITableView!
    @IBOutlet var attachmentContainerV: UIView!
    @IBOutlet var chatFieldBottomC: NSLayoutConstraint!
    @IBOutlet var chatTV: UITextView!
    @IBOutlet var chatTVHeightC: NSLayoutConstraint!
    @IBOutlet var chatContainerV: UIView!
    
    @IBOutlet var chatBarSV: UIStackView!
    
    private var disposeBag: DisposeBag = DisposeBag()
    private var isAttachmentShow = false
    private var messages:[Chat] = []
    private var keyboardHeight:CGFloat = 0
    
    var dialog: Dialog?
    var userRole: String = UserRole.BUYER
    
    var reloadedImageIdx:[Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        self.setupNavigationBar()
        self.setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupData()
        self.observeViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.chatTableV.register(UINib(nibName: "ChatTextTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTextCell")
        self.chatTableV.register(UINib(nibName: "ChatImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatImageCell")
        self.chatTableV.register(UINib(nibName: "QuotationTableViewCell", bundle: nil), forCellReuseIdentifier: "QuotationCell")
        self.chatTableV.register(UINib(nibName: "RequestTableViewCell", bundle: nil), forCellReuseIdentifier: "RequestCell")
        self.chatTableV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
                
        self.chatTV.textContainer.lineFragmentPadding = 0
        self.chatTV.textContainerInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        self.chatTVHeightC.constant = self.chatTV.contentSize.height
            
        self.attachmentContainerV.isHidden = true
    }
    
    private func setupData(){
        guard let dialog = dialog else { return }
        MessagingVM.shared.getAllMessages(dialogId: dialog.id)
    }
    
    private func observeViewModel(){
        MessagingVM.shared.messages.bind { (messages) in
            SVProgressHUD.dismiss()
            
            self.messages = messages
            self.chatTableV.reloadData()
            if self.messages.count > 0{
                self.chatTableV.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
            }
        }.disposed(by: disposeBag)
        
        RequestVM.shared.requestQuotation.bind{ (requestQuotation) in
            SVProgressHUD.dismiss()
            
            let requestDetailVC = RequestDetailViewController()
            requestDetailVC.userRole = self.userRole
            requestDetailVC.requestQuotation = requestQuotation
            self.navigationController?.pushViewController(requestDetailVC, animated: true)
        }.disposed(by: disposeBag)
        
        RequestVM.shared.errorMsg.bind{ (errorMsg) in
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func setupNavigationBar(){
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 50))
        view.backgroundColor = .red
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 21))
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        
        guard let user = UserDefaultHelper.shared.getUser(), let dialog = dialog else { return }
        let currentUserEmail = (userRole == Role.BUYER) ? user.buyerEmail : user.sellerEmail
        guard let occupant = dialog.occupants.first(where: { $0.email != currentUserEmail }) else { return }
        label.text = occupant.name
        
        view.addSubview(label)
        self.navigationItem.titleView = label
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func presentImagePickerController(sourceType: UIImagePickerController.SourceType){
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = sourceType
        imagePickerVC.delegate = self
        imagePickerVC.modalPresentationStyle = .fullScreen
        
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .systemBlue
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        self.present(imagePickerVC, animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.chatContainerV.frame.origin.y == 0 {
                self.keyboardHeight = keyboardSize.height
                
                if #available(iOS 13.0, *) {
                    let window = UIApplication.shared.windows[0]
                    let bottomPadding = window.safeAreaInsets.bottom
                    self.chatFieldBottomC.constant = self.keyboardHeight - bottomPadding
                }else{
                    let window = UIApplication.shared.keyWindow
                    let bottomPadding = window?.safeAreaInsets.bottom
                    self.chatFieldBottomC.constant = self.keyboardHeight - (bottomPadding ?? 0)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.chatFieldBottomC.constant = 0
    }
    
    @IBAction func makeQuotationAction(_ sender: Any) {
        let createQuotationVC = CreateQuotationViewController()
        self.navigationController?.pushViewController(createQuotationVC, animated: true)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        guard let dialog = dialog else {return}
        MessagingVM.shared.sendTextChat(dialogId: dialog.id, text: self.chatTV.text!)
        self.chatTV.text = ""
    }
    
    @IBAction func attachmentAction(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.attachmentContainerV.isHidden = !self.attachmentContainerV.isHidden
            self.chatBarSV.layoutIfNeeded()
        }
    }
    
    @IBAction func selectImageAction(_ sender: Any) {
        let alert = UIAlertController(title: "Upload Image", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.presentImagePickerController(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.presentImagePickerController(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.item]
        let user = UserDefaultHelper.shared.getUser()!
        let currentUserEmail = (userRole == UserRole.BUYER) ? user.buyerEmail : user.sellerEmail
        
        switch message.type {
            case MessageType.TEXT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTextCell") as! ChatTextTableViewCell
                cell.messageL.text = message.content.text
                return cell
            case MessageType.REQUEST_FOR_QUOTATION:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell") as! RequestTableViewCell
                cell.delegate = self
                cell.index = indexPath.item
                
                if self.messages[indexPath.item].senderEmail == currentUserEmail{
                    cell.requestLeadingC.priority = UILayoutPriority(rawValue: 1000)
                    cell.requestTrailingC.priority = UILayoutPriority(rawValue: 250)
                    cell.containerV.backgroundColor = .white

                    cell.requestIV.tintColor = Color.PRIMARY_COLOR
                    cell.titleL.textColor = .black
                    cell.requestTitleL.textColor = Color.ORANGE_COLOR
                }else{
                    cell.requestLeadingC.priority = UILayoutPriority(rawValue: 250)
                    cell.requestTrailingC.priority = UILayoutPriority(rawValue: 1000)

                    cell.containerV.backgroundColor = Color.PRIMARY_COLOR

                    cell.requestIV.tintColor = .white
                    cell.titleL.textColor = .white
                    cell.requestTitleL.textColor = .white
                }
                
                cell.requestTitleL.text = message.content.requestDescription
                
                return cell
            case MessageType.QUOTATION:
                let cell = tableView.dequeueReusableCell(withIdentifier: "QuotationCell", for: indexPath) as! QuotationTableViewCell

                cell.delegate = self
                cell.index = indexPath.item

                if self.messages[indexPath.item].senderEmail == currentUserEmail{
                    cell.quotationLeadingC.priority = UILayoutPriority(rawValue: 1000)
                    cell.quotationTrailingC.priority = UILayoutPriority(rawValue: 250)
                    cell.containerV.backgroundColor = .white

                    cell.titleL.textColor = .black
                    cell.productNameL.textColor = .black
                }else{
                    cell.quotationLeadingC.priority = UILayoutPriority(rawValue: 250)
                    cell.quotationTrailingC.priority = UILayoutPriority(rawValue: 1000)
                    cell.containerV.backgroundColor = Color.PRIMARY_COLOR

                    cell.titleL.textColor = .white
                    cell.productNameL.textColor = .white
                    cell.productPriceL.textColor = .white
                }
                
                cell.productNameL.text = message.content.productName
                let priceStr = String(message.content.price!)
                cell.productPriceL.text = priceStr
                let price = CurrencyHelper.shared.formatCurrency(price: priceStr)
                cell.productPriceL.text = String(format: "Rp. %@", price!)
                if let imageUrlStr = message.content.productImage{
                    if let imageUrl = URL(string: Network.ASSET_URL + imageUrlStr){
                        cell.productImageIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                    }
                }
                
                return cell
            case MessageType.IMAGE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatImageCell") as! ChatImageTableViewCell
                cell.index = indexPath.item
                cell.delegate = self
                cell.chatImageIVHeightC.constant = 0

                if self.messages[indexPath.item].senderEmail == currentUserEmail{
                    cell.chatImageIVLeadingC.priority = UILayoutPriority(rawValue: 1000)
                    cell.chatImageIVTrailingC.priority = UILayoutPriority(rawValue: 250)
                }else{
                    cell.chatImageIVLeadingC.priority = UILayoutPriority(rawValue: 250)
                    cell.chatImageIVTrailingC.priority = UILayoutPriority(rawValue: 1000)
                }
                
                cell.chatImageIV.backgroundColor = .white
                if let imageUrlString = message.content.path{
                    if let imageUrl = URL(string: String(format: "%@%@", Network.ASSET_URL, imageUrlString)){
                        cell.chatImageIV.af.setImage(withURL: imageUrl, completion:  { image in
                            guard let image = image.value else {return}
                            
                            cell.chatImageIV.backgroundColor = nil
                            let ratio = image.size.height/image.size.width
                            let imageViewWidth = cell.frame.width * 0.5
                            cell.chatImageIVHeightC.constant = (imageViewWidth * CGFloat(ratio))
                            
                            if self.reloadedImageIdx.first(where: {$0 == indexPath.item}) == nil{
                                DispatchQueue.main.async {
                                    self.chatTableV.reloadData()
                                    self.chatTableV.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                                }
                                self.reloadedImageIdx.append(indexPath.item)
                            }
                        })
                    }
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTextCell") as! ChatTextTableViewCell
                cell.messageL.text = "-"
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let type = (self.messages[indexPath.item].customParameters["type"] as? String){
//            if type == ChatItemType.IMAGE{
//                // MARK: Setup chat image cell size based on aspect ratio
//                if let imageHeight = self.messages[indexPath.item].customParameters["height"] as? String, let imageWidth = self.messages[indexPath.item].customParameters["width"] as? String{
//                    let ratio = Double(imageHeight)!/Double(imageWidth)!
//                    let imageViewWidth = self.chatTableV.frame.width * 0.5
//
//                    return imageViewWidth * CGFloat(ratio) + 16
//                }
//            }
//        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let type = (self.messages[indexPath.item].customParameters["type"] as? String), type == ChatItemType.REQUEST{
//            if let requestQuotationJson = self.messages[indexPath.item].customParameters["request_quotation"]{
//                do{
//                    let data: Data = (requestQuotationJson as! String).data(using: .utf8)!
//                    let requestQuotation = try JSONDecoder().decode(RequestQuotation.self, from: data)
//
//                    let requestDetailVC = RequestDetailViewController()
//                    requestDetailVC.qbDialog = self.qbDialog
//                    requestDetailVC.userRole = self.userRole
//                    requestDetailVC.requestQuotation = requestQuotation
//                    requestDetailVC.buyerQbUserId = self.messages[indexPath.item].senderID
//                    self.navigationController?.pushViewController(requestDetailVC, animated: true)
//                }catch(let error){
//                    print(error)
//                    SVProgressHUD.showError(withStatus: error.localizedDescription)
//                    SVProgressHUD.dismiss()
//                }
//            }
//
//        }
        
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // MARK: Get file name
        guard let fileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }

        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }

        SVProgressHUD.show()
        
        guard let dialog = dialog else {return}
        MessagingVM.shared.sendImageChat(dialogId: dialog.id, image: image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
    }
}

extension ChatViewController: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            textView.textColor = UIColor.black
        }
        self.chatTableV.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.contentSize.height >= 24{
            self.chatTVHeightC.constant = textView.contentSize.height
        }else{
            self.chatTVHeightC.constant = 24
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter a message"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension ChatViewController: ChatDelegate{
    func didSelectImage(index:Int){
        let imagePreviewVC = ImagePreviewViewController()
        
        imagePreviewVC.modalTransitionStyle = .crossDissolve
        imagePreviewVC.modalPresentationStyle = .overCurrentContext
        self.present(imagePreviewVC, animated: true, completion: {
//            if let imageUrl = URL(string: self.messages[index].customParameters["image_url"] as! String){
//                imagePreviewVC.photoIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
//            }
        })
    }
    
    func didSelectQuotation(index: Int) {
        print("(DEBUG) DID SELECT QUOTATION")
        guard let quotationId = self.messages[index].content.orderId else {return}
        
//        SVProgressHUD.show()
        QuotationVM.shared.getQuotationDetail(quotationId: quotationId)
//        do {
//            let user = UserDefaultHelper.shared.getUser()!
//            let currentUserEmail = (userRole == UserRole.BUYER) ? user.buyerEmail : user.sellerEmail
//
//            if self.messages[index].senderEmail == currentUserEmail{
//                let quotationDetailVC = QuotationDetailViewController()
////                quotationDetailVC.quotationResp = try JSONDecoder().decode(QuotationResp.self, from: data)
//                self.navigationController?.pushViewController(quotationDetailVC, animated: true)
//            }else{
//                let checkoutVC = CheckoutViewController()
////                checkoutVC.quotationResp` = try JSONDecoder().decode(QuotationResp.self, from: data)
//                self.navigationController?.pushViewController(checkoutVC, animated: true)
//            }
//        } catch (let error) {
//            SVProgressHUD.showError(withStatus: error.localizedDescription)
//            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
//        }
    }
    
    func didSelectRequestQuotation(index: Int?){
        guard let index = index else {
            SVProgressHUD.showError(withStatus: "Index Missing!")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            
            return
        }
        let message = messages[index]
        
        guard let requestQuotationId = message.content.requestQuotationId else {
            SVProgressHUD.showError(withStatus: "Request Quotation Id Missing!")
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            
            return
        }
        
        SVProgressHUD.show()
        RequestVM.shared.getRequestDetail(id: requestQuotationId)
    }
}
