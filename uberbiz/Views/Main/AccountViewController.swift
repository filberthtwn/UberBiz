//
//  AccountViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

protocol AccountProtocol {
    func didEditStoreSucceed()
}

class AccountViewController: UIViewController {

    @IBOutlet var accountCollectionView: UICollectionView!
    @IBOutlet var horizontalBarLeft: NSLayoutConstraint!
    
    @IBOutlet var tabLayoutLabels: [UILabel]!
    
    private var disposeBag:DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupData()
        self.observeViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        self.accountCollectionView.register(UINib(nibName: "BuyerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BuyerCell")
        self.accountCollectionView.register(UINib(nibName: "SellerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SellerCell")
    }
    
    private func setupData(){
        UserVM.shared.getUserDetail()
    }
    
    private func observeViewModel(){
        
        self.disposeBag = DisposeBag()
        
        UserVM.shared.isLogoutSuccess.bind { (isSuccess) in
            self.disposeBag = DisposeBag()
            
            self.logoutUser()
        }.disposed(by: disposeBag)
        
        UserVM.shared.user.bind { (user) in
            do{
                if let currentUser = UserDefaultHelper.shared.getUser(){
                    var newUser = user
                    print(user)
                    newUser.accessToken = currentUser.accessToken
                    let data = try JSONEncoder().encode(newUser)
                    UserDefaultHelper.shared.setupUser(data: data)
                    DispatchQueue.main.async {
                        self.accountCollectionView.reloadData()
                        self.accountCollectionView.layoutIfNeeded()
                    }
                }
            }catch (let error){
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                SVProgressHUD.dismiss(withDelay: Delay.SHORT)
            }
        }.disposed(by: disposeBag)
        
        UserVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            self.logoutUser()
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func logoutUser(){
        SVProgressHUD.dismiss()
        
        UserDefaultHelper.shared.deleteUser()
        
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.horizontalBarLeft.constant = scrollView.contentOffset.x/2
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/self.view.frame.width)
        self.setupTabLayout(selectedIdx: index)
    }
        
    private func setupTabLayout(selectedIdx:Int){
        for (index, element) in self.tabLayoutLabels.enumerated() {
            if (index == selectedIdx){
                element.textColor = .black
            }else{
                element.textColor = Color.TABBAR_INACTIVE_COLOR
            }
        }
    }
    
    @IBAction func didTapLayoutTapped(_ sender: UIButton) {
        self.setupTabLayout(selectedIdx: sender.tag)
        self.accountCollectionView.scrollToItem(at: IndexPath(item: sender.tag, section: 0), at: .left, animated: true)
    }
}

extension AccountViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.accountCollectionView.frame.width, height: self.accountCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.item == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BuyerCell", for: indexPath) as! BuyerCollectionViewCell
            cell.delegate = self
            cell.user = UserDefaultHelper.shared.getUser()
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SellerCell", for: indexPath) as! SellerCollectionViewCell
            cell.delegate = self
            cell.user = UserDefaultHelper.shared.getUser()
            return cell
        }
    }
}

extension AccountViewController:BuyerProtocol{
    func didLoginTapped(){
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.sourceVC = LoginSourceVC.ACCOUNT
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func didMyOrderTapped() {
        self.navigationController?.pushViewController(MyOrderViewController(), animated: true)
    }
    
    func didEditProfileTapped() {
        self.navigationController?.pushViewController(EditProfileViewController(), animated: true)
    }
    
    func didCreateRequestTapped() {
        self.navigationController?.pushViewController(CreateRequestViewController(), animated: true)
    }
    
    func didLogoutTapped() {
        SVProgressHUD.show()
    }
}

extension AccountViewController: SellerProtocol{
    func didBuyeOrderTapped() {
        self.navigationController?.pushViewController(BuyerOrderViewController(), animated: true)
    }
    
    func didEditStoreTapped() {
        let editStoreVC = EditStoreViewController()
        editStoreVC.delegate = self
        self.navigationController?.pushViewController(editStoreVC, animated: true)
    }
    
    func didMyProductTapped() {
        self.navigationController?.pushViewController(MyProductViewController(), animated: true)
    }
    
    func didAddProductTapped() {
        self.navigationController?.pushViewController(AddProductViewController(), animated: true)
    }
    
    func didSellerLogoutTapped() {
        SVProgressHUD.show()
    }
    
    func didWithdrawTapped() {
        self.navigationController?.pushViewController(CreateWithdrawViewController(), animated: true)
    }
    
    func didSignUpSellerTapped() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.sourceVC = LoginSourceVC.ACCOUNT
        self.present(loginVC, animated: true, completion: nil)
    }
}

extension AccountViewController: AccountProtocol{
    func didEditStoreSucceed(){
        self.accountCollectionView.reloadData()
    }
}
