//
//  MessengerViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

protocol MessengerProtocol {
    func didSelect(index:Int)
}

class MessengerViewController: UIViewController {

//    @IBOutlet var messengerTableView: UITableView!
    @IBOutlet var messengerCV: UICollectionView!
    @IBOutlet var horizontalBarLeft: NSLayoutConstraint!
    
    @IBOutlet var tabLayoutLabels: [UILabel]!
    
    private var selectedIndex = 0
    private var isDataLoaded = false
//    private var qbDialogs:[QBChatDialog] = []
    private var disposeBag:DisposeBag = DisposeBag()
    
    private var dialogs: [Dialog] = []
    
    private var selectedRole:String = UserRole.BUYER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.disposeBag = DisposeBag()
    }
    
    private func setupViews(){
        self.messengerCV.register(UINib(nibName: "MessengerSectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MessengerSectionCell")
    }
    
    func setupData(index: Int){
        self.disposeBag = DisposeBag()
        self.observeViewModel()
                
        self.isDataLoaded = false
        self.dialogs.removeAll()
        self.messengerCV.reloadData()
        
        self.selectedIndex = index
        self.selectedRole = (selectedIndex == 0 ) ? UserRole.BUYER : UserRole.SELLER
        
        if let user = UserDefaultHelper.shared.getUser(){
            let email = (selectedRole == UserRole.BUYER) ? user.buyerEmail : user.sellerEmail
            MessagingVM.shared.getAllDialog(email: email)
        }
        
        self.messengerCV.reloadData()
    }
    
    private func observeViewModel(){
        MessagingVM.shared.dialogs.bind { (dialogs) in
            self.dialogs = dialogs
            self.isDataLoaded = true
            self.messengerCV.reloadData()
        }.disposed(by: disposeBag)
        
        MessagingVM.shared.errMsg.bind { (errMsg) in
            SVProgressHUD.showError(withStatus: errMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    private func clearData(){
        self.isDataLoaded = false
        self.dialogs.removeAll()
        self.messengerCV.reloadData()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.horizontalBarLeft.constant = scrollView.contentOffset.x/2
        self.clearData()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/self.view.frame.width)
        self.setupData(index: index)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/self.view.frame.width)
        self.setupTabLayout(selectedIdx: index)
        
        self.setupData(index: index)
    }

    @IBAction func didTapLayoutTapped(_ sender: UIButton) {
        self.setupTabLayout(selectedIdx: sender.tag)
        self.messengerCV.scrollToItem(at: IndexPath(item: sender.tag, section: 0), at: .left, animated: true)
        
        self.clearData()
//        self.setupData(index: sender.tag)
    }
}

extension MessengerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.messengerCV.frame.width, height: self.messengerCV.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessengerSectionCell", for: indexPath) as! MessengerSectionCollectionViewCell
        cell.delegate = self
        cell.selectedRole = self.selectedRole
        cell.isDataLoaded = self.isDataLoaded
        cell.dialogs = dialogs
        
        return cell
    }
}

extension MessengerViewController: MessengerProtocol{
    func didSelect(index: Int) {
        let chatVC = ChatViewController()
//        chatVC.title =
        chatVC.dialog = dialogs[index]
        chatVC.userRole = self.selectedRole
//        chatVC.qbDialog = self.dialogs[index]
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
