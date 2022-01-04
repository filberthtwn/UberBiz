//
//  EditStoreViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

struct EditStoreImageType {
    static let PROFILE_PICTURE = "PROFILE_PICTURE"
    static let NPWP = "NPWP"
    static let DEED = "DEED"
}

protocol EditStoreDelegate {
    func didSelectAddress(address:Address)
}

class EditStoreViewController: UIViewController {

    @IBOutlet var storeNameTF: UITextField!
    @IBOutlet var storeDescTV: UITextView!
    @IBOutlet var storeAddressTF: UITextField!
    
    @IBOutlet var addressV: UIView!
    @IBOutlet var addAddressV: UIView!
    @IBOutlet var deleteVs: [UIView]!
    
    @IBOutlet var npwpDashedV: UberBizDashedView!
    @IBOutlet var companyDeedDashedV: UberBizDashedView!
    
    @IBOutlet var storeImageView: UIImageView!
    @IBOutlet var verifiedStatusIV: UIImageView!
    @IBOutlet var npwpIV: UIImageView!
    @IBOutlet var companyDeedIV: UIImageView!
    @IBOutlet var saveButton: UIButton!
    
    private var storeProfileImageUrl:String?
    private var npwpImageUrl:String?
    private var companyDeedImageUrl:String?

    
    @IBOutlet var imageBtns: [UIButton]!
    @IBOutlet var imagePreviewBtns: [UIButton]!
    
    @IBOutlet var heightC: NSLayoutConstraint!
    
    var delegate: AccountProtocol?
    private var pickedImage:UIImage?
    private var imageType = EditStoreImageType.PROFILE_PICTURE
    private var disposeBag:DisposeBag = DisposeBag()
    private var updateMessage:String = ""
    private var selectedAddress: Address?
    private var userVM = UserVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupDefaultValue()
        self.observeViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let address = self.selectedAddress{
            let fullAddress = address.fullAddress
            let district = address.district
            let province = (address.province?.provinceName) ?? ""
            let city = (address.city?.cityName) ?? ""
            let postalCode = address.postalCode
            
            let address = String(format: "%@, %@, %@, %@, %@", fullAddress, district, city, province, postalCode)
            self.storeAddressTF.text = address
            self.addressV.isHidden = false
            self.addAddressV.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isMovingFromParent{
            self.disposeBag = DisposeBag()
        }
    }
    
    private func setupViews(){
        self.title = "Edit Store"
        self.storeImageView.layer.cornerRadius = self.storeImageView.frame.width/2
        self.saveButton.layer.cornerRadius = 6
        
        self.storeDescTV.textContainer.lineFragmentPadding = 0
        self.heightC.constant = 32
        
        for deleteV in self.deleteVs {
            deleteV.layer.cornerRadius = deleteV.frame.height/2
            deleteV.isHidden = true
        }
        
        self.npwpIV.layer.cornerRadius = 6
        self.companyDeedIV.layer.cornerRadius = 6
    }
    
    private func setupDefaultValue(){
        if let user = UserDefaultHelper.shared.getUser(){
            self.storeNameTF.text = user.storeName
            self.storeDescTV.text = user.storeDescription
            
            if let imageUrlStr = user.storeImageUrl, let imageUrl = URL(string: Network.ASSET_URL + imageUrlStr) {
                self.storeImageView.af.setImage(withURL: imageUrl)
            }
            
            if let storeAddress = user.storeAddress{
                self.addressV.isHidden = false
                self.addAddressV.isHidden = true
                
                let storeAddressStr = String(format: "%@, %@, %@, %@, %@",  storeAddress.fullAddress,  storeAddress.district, (storeAddress.city?.cityName) ?? "", (storeAddress.province?.provinceName) ?? "", storeAddress.postalCode)
                self.storeAddressTF.text = storeAddressStr
                
                self.selectedAddress = storeAddress
                
                if let sellerDocs = user.sellerDocs{
                    switch sellerDocs.status.statusName {
                    case VerificationStatus.VERIFIED:
                        self.verifiedStatusIV.image = UIImage(named: "verified-icon")
                    case VerificationStatus.REJECT:
                        self.verifiedStatusIV.image = UIImage(named: "rejected-icon")
                    default:
                        self.verifiedStatusIV.image = UIImage(named: "waiting-icon")
                    }
                    
                    if let npwpImageUrlStr = sellerDocs.npwpImageUrl{
                        self.npwpImageUrl = npwpImageUrlStr
                        if let npwpImageUrl = URL(string: Network.ASSET_URL + npwpImageUrlStr){
                            self.showNpwpPreview()
                            self.npwpIV.af.setImage(withURL: npwpImageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                        }
                    }
                    
                    if let deedImageUrlStr = sellerDocs.deedImageUrl{
                        self.companyDeedImageUrl = deedImageUrlStr
                        if let deedImageUrl = URL(string: Network.ASSET_URL + deedImageUrlStr){
                            self.showDeedPreview()
                            self.companyDeedIV.af.setImage(withURL: deedImageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                        }
                    }
                    
                    if sellerDocs.status.statusName == VerificationStatus.VERIFIED{
                        for deleteV in self.deleteVs{
                            deleteV.isHidden = true
                        }
                    }
                    
                }else{
                    self.verifiedStatusIV.isHidden = true
                }
            }
        }
    }
    
    private func observeViewModel(){
        AddressVM.shared.address.bind { (address) in
            var user = self.createUserObject()
            user.storeAddress = address
            self.userVM.updateUser(user: user)
        }.disposed(by: disposeBag)
        
        userVM.imageUrl.bind { (imageUrl) in
            SVProgressHUD.dismiss()
            switch self.imageType {
                case EditStoreImageType.PROFILE_PICTURE:
                    self.storeProfileImageUrl = imageUrl
                    self.storeImageView.image = self.pickedImage
                case EditStoreImageType.NPWP:
                    self.npwpImageUrl = imageUrl
                    self.showNpwpPreview()
                    self.npwpIV.image = self.pickedImage
                default:
                    self.companyDeedImageUrl = imageUrl
                    self.showDeedPreview()
                    self.companyDeedIV.image = self.pickedImage
            }
        }.disposed(by: disposeBag)
        
        userVM.message.bind { (message) in
            self.updateMessage = message
            self.userVM.getUserDetail()
        }.disposed(by: disposeBag)
        
        userVM.user.bind { (user) in
            if let currentUser = UserDefaultHelper.shared.getUser(){
                var newUserData = user
                newUserData.accessToken = currentUser.accessToken
                
                do{
                    let data = try JSONEncoder().encode(newUserData)
                    UserDefaultHelper.shared.setupUser(data: data)
                    
                    SVProgressHUD.showSuccess(withStatus: self.updateMessage)
                    SVProgressHUD.dismiss(withDelay: Delay.SHORT)
                                        
                    self.delegate?.didEditStoreSucceed()
                    
                    self.navigationController?.popViewController(animated: true)
                }catch(let error){
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    SVProgressHUD.dismiss()
                }
            }
            
        }.disposed(by: disposeBag)
        
        userVM.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func showNpwpPreview(){
        self.deleteVs[0].isHidden = false
        self.imageBtns[0].isHidden = true
        self.imagePreviewBtns[0].isHidden = false
        self.npwpDashedV.isHidden = true
        self.npwpIV.isHidden = false
    }
    
    private func showDeedPreview(){
        self.deleteVs[1].isHidden = false
        self.imageBtns[1].isHidden = true
        self.imagePreviewBtns[1].isHidden = false
        self.companyDeedDashedV.isHidden = true
        self.companyDeedIV.isHidden = false
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
    
    private func isValid()->Bool{
        if self.storeNameTF.text! == ""{
            return false
        }
        
        if self.storeDescTV.text! == ""{
            return false
        }
        return true
    }
    
    private func showImagePickerModal(){
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
    
    private func createUserObject() -> User{
        var user = User()
        user.storeName = self.storeNameTF.text!
        user.storeDescription = self.storeDescTV.text!
        user.storeImageUrl = self.storeProfileImageUrl
        user.storeAddress = self.selectedAddress
        user.npwpImageUrl = self.npwpImageUrl
        user.companyDeedImageUrl = self.companyDeedImageUrl
                
        return user
    }
    
    @IBAction func changeAddressAction(_ sender: Any) {
        let addAddressVC = AddAddressViewController()
        addAddressVC.currentAddress = self.selectedAddress
        addAddressVC.editStoreDelegate = self
        addAddressVC.sourceVC = AddAddressSource.EDIT_PROFILE
        self.navigationController?.pushViewController(addAddressVC, animated: true)
    }
    
    @IBAction func changePictureAction(_ sender: Any) {
        self.imageType = EditStoreImageType.PROFILE_PICTURE
        self.showImagePickerModal()
    }
    
    @IBAction func imagePreviewAction(_ sender: UIButton) {
        let imagePreviewVC = ImagePreviewViewController()
        imagePreviewVC.modalTransitionStyle = .crossDissolve
        imagePreviewVC.modalPresentationStyle = .overCurrentContext
        if sender.tag == 0{
            imagePreviewVC.image = self.npwpIV.image!
        }else{
            imagePreviewVC.image = self.companyDeedIV.image!
        }
        self.present(imagePreviewVC, animated: true, completion: nil)
    }
    
    @IBAction func addAddressAction(_ sender: Any) {
        let addAddressVC = AddAddressViewController()
        addAddressVC.sourceVC = AddAddressSource.EDIT_PROFILE
        self.navigationController?.pushViewController(addAddressVC, animated: true)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if sender.tag == 0{
            self.npwpImageUrl = nil
            self.deleteVs[sender.tag].isHidden = true
            self.imageBtns[sender.tag].isHidden = false
            self.imagePreviewBtns[sender.tag].isHidden = true
            self.npwpDashedV.isHidden = false
            
            self.npwpIV.isHidden = true
            self.npwpIV.image = nil
        }else{
            self.companyDeedImageUrl = nil

            self.deleteVs[sender.tag].isHidden = true
            self.imageBtns[sender.tag].isHidden = false
            self.imagePreviewBtns[sender.tag].isHidden = true
            self.companyDeedDashedV.isHidden = false
            
            self.companyDeedIV.isHidden = true
            self.companyDeedIV.image = nil
        }
    }
    
    @IBAction func uploadNPWP(_ sender: Any) {
        self.imageType = EditStoreImageType.NPWP
        self.showImagePickerModal()
    }
    
    @IBAction func uploadCompanyDeed(_ sender: Any) {
        self.imageType = EditStoreImageType.DEED
        self.showImagePickerModal()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if self.isValid(){
            SVProgressHUD.show()
            if let storeAddress = self.createUserObject().storeAddress{
                AddressVM.shared.createAddress(address: storeAddress)
            }else{
                userVM.updateUser(user: self.createUserObject())
            }
        }else{
            SVProgressHUD.showError(withStatus: Message.FILL_THE_BLANKS)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }
    }
}

extension EditStoreViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        self.pickedImage = image
        
        SVProgressHUD.show()
        
        
        switch self.imageType {
        case EditStoreImageType.PROFILE_PICTURE:
            userVM.uploadProfileImage(image: image)
        case EditStoreImageType.NPWP:
            userVM.uploadSellerDocument(image: image, type: EditStoreImageType.NPWP)
        default:
            userVM.uploadSellerDocument(image: image, type: EditStoreImageType.DEED)
        }
        
        self.view.layoutIfNeeded()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
    }
    
}

extension EditStoreViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if textView.contentSize.height <= 50{
            self.heightC.constant = textView.contentSize.height
        }
    }
}
extension EditStoreViewController: EditStoreDelegate{
    func didSelectAddress(address: Address) {
        self.selectedAddress = address
    }
}
