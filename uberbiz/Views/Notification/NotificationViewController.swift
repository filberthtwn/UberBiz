//
//  NotificationViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/01/21.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationViewController: UIViewController {

    @IBOutlet var notificationCollectionView: UICollectionView!
    
    @IBOutlet var tabLayoutLabels: [UILabel]!
    @IBOutlet var horizontalBarLeft: NSLayoutConstraint!
    
    private var notifications: [Notification] = []{
        didSet{
            self.notificationCollectionView.reloadData()
        }
    }
    private var isDataLoaded: Bool = false
    private var disposeBag = DisposeBag()
    
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.setupData(index: 0)
        self.observeViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.isMovingFromParent{
            self.disposeBag = DisposeBag()
        }
    }
    
    private func setupViews(){
        self.title = "Notifications"
        self.notificationCollectionView.register(UINib(nibName: "NotificationTableCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NotificationCell")
    }
    
    private func setupData(index: Int){
        self.isDataLoaded = false
        self.notifications.removeAll()
        
        self.selectedIndex = index
        
        if index == 0{
            NotificationVM.shared.getNotifications(role: Role.BUYER, paginate: 100)
        }else if index == 1{
            NotificationVM.shared.getNotifications(role: Role.SELLER, paginate: 100)
        }
    }
    
    private func observeViewModel(){
        NotificationVM.shared.notifications.bind { (notifications) in
            self.isDataLoaded = true
            self.notifications = notifications
            self.notificationCollectionView.reloadData()
        }.disposed(by: disposeBag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.horizontalBarLeft.constant = scrollView.contentOffset.x/2
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
    
    private func setupTabLayout(selectedIdx:Int){
        for (index, element) in self.tabLayoutLabels.enumerated() {
            if (index == selectedIdx){
                element.textColor = .black
            }else{
                element.textColor = Color.TABBAR_INACTIVE_COLOR
            }
        }
        
    }
    
    @IBAction func didTabLayoutTapped(_ sender: UIButton) {
        self.setupTabLayout(selectedIdx: sender.tag)
        self.notificationCollectionView.scrollToItem(at: IndexPath(item: sender.tag, section: 0), at: .left, animated: true)        
    }
}

extension NotificationViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.notificationCollectionView.frame.width, height: self.notificationCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCell", for: indexPath) as! NotificationTableCollectionViewCell
        if indexPath.item != selectedIndex{
            cell.isDataLoaded = false
            cell.notifications = []
        }else{
            cell.isDataLoaded = self.isDataLoaded
            cell.notifications = self.notifications
        }
        return cell
    }
    
}

