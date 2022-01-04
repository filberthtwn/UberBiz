//
//  MyOrderViewController.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class MyOrderViewController: UIViewController {

    @IBOutlet var orderStatusCollectionView: UICollectionView!
    @IBOutlet var orderTableCollectionView: UICollectionView!
    
    private var orders:[Order] = []
    private let orderStatus = ["Menunggu Konfirmasi", "Dikirim", "Selesai"]
    private let orderStatusKey = ["UNPAID", "PROCESSED", "COMPLETED"]
    
    var selectedStatusIdx = 0
    var isDataLoaded:Bool = false
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        
        self.setupData(status: self.orderStatusKey[0])
        self.observeViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            self.disposeBag = DisposeBag()
        }
    }
    
    private func setupViews(){
        self.title = "My Orders"
        self.orderStatusCollectionView.register(UINib(nibName: "OrderStatusCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrderStatusCell")
        self.orderTableCollectionView.register(UINib(nibName: "OrderTableCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrderTableCell")
    }
    
    private func setupData(status:String){
        self.orders = []
        self.isDataLoaded = false
        self.orderTableCollectionView.reloadData()
        
        OrderVM.shared.getOrders(status: status, isSeller: false)
    }
    
    private func observeViewModel(){
        OrderVM.shared.orders.bind { (orders) in
            self.orders = orders
                        
            self.isDataLoaded = true
            self.orderTableCollectionView.reloadData()
        }.disposed(by: disposeBag)
        
        OrderVM.shared.errorMsg.bind { (errorMsg) in
            guard let errorMsg = errorMsg else {return}
            
            SVProgressHUD.showError(withStatus: errorMsg)
            SVProgressHUD.dismiss(withDelay: Delay.SHORT)
        }.disposed(by: disposeBag)
    }
    
    func updateOrderStatus(){
        self.orderStatusCollectionView.scrollToItem(at: IndexPath(item: self.selectedStatusIdx, section: 0), at: .left, animated: true)
        self.orderStatusCollectionView.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.tag == 1){
            self.selectedStatusIdx = Int(scrollView.contentOffset.x/self.orderTableCollectionView.frame.width)
            self.setupData(status: self.orderStatusKey[self.selectedStatusIdx])
            self.updateOrderStatus()
        }
    }
    
}

extension MyOrderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (collectionView == self.orderStatusCollectionView){
            let label = UILabel(frame: CGRect.zero)
            label.text = self.orderStatus[indexPath.item]
            label.sizeToFit()
            return CGSize(width: label.frame.width + 48, height: self.orderStatusCollectionView.frame.height)
        }else{
            return CGSize(width: self.orderTableCollectionView.frame.width, height: self.orderTableCollectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.orderStatusCollectionView){
            self.selectedStatusIdx = indexPath.item
            self.orderTableCollectionView.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredVertically, animated: true)
            self.setupData(status: self.orderStatusKey[indexPath.item])
            
            self.updateOrderStatus()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderStatus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView == self.orderStatusCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderStatusCell", for: indexPath) as! OrderStatusCollectionViewCell
            cell.statusLabel.text = self.orderStatus[indexPath.item]
            if (indexPath.item == self.selectedStatusIdx){
                cell.statusLabel.textColor = .black
                cell.horizontalBar.isHidden = false
            }else{
                cell.statusLabel.textColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25)
                cell.horizontalBar.isHidden = true
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderTableCell", for: indexPath) as! OrderTableCollectionViewCell
            cell.delegate = self
            cell.isDataLoaded = self.isDataLoaded
            cell.orders = self.orders
            
            cell.prepareForReuse()
            return cell
        }
    }
}

extension MyOrderViewController: OrderProtocol{
    func didOrderTapped(order: Order) {
        let orderDetailVC = OrderDetailViewController()
        orderDetailVC.order = order
        self.navigationController?.pushViewController(orderDetailVC, animated: true)
    }
    
    func didConfirmAction() {
        let popup_orderConfirmVC = Popup_OrderConfirmationViewController()
        self.present(popup_orderConfirmVC, animated: true, completion: nil)
    }
}
