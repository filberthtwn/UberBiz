//
//  BuyerOrderTableCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 10/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class BuyerOrderTableCollectionViewCell: UICollectionViewCell {

    @IBOutlet var buyerOrderTableView: UITableView!
    
    var delegate: OrderProtocol?    
    var orders:[Order] = []{
        didSet{
            self.buyerOrderTableView.reloadData()
        }
    }
    var status: String?
    var isDataLoaded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.buyerOrderTableView.delegate = self
        self.buyerOrderTableView.dataSource = self
        self.buyerOrderTableView.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.buyerOrderTableView.register(UINib(nibName: "DefaultOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultOrderCell")
    }
}

extension BuyerOrderTableCollectionViewCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.orders.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didOrderTapped(order: self.orders[indexPath.item])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultOrderCell", for: indexPath) as! DefaultOrderTableViewCell
            cell.listingNameL.text = self.orders[indexPath.item].quotation!.product!.itemName
            cell.listingPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: self.orders[indexPath.item].quotation!.product!.price)! + "/" + self.orders[indexPath.item].quotation!.product!.unit.unitName
            cell.listingQuantityL.text = String(self.orders[indexPath.item].quantity) + " " + self.orders[indexPath.item].quotation!.product!.unit.unitName
            if self.orders[indexPath.item].quotation!.product!.images.count > 0{
                if let imageUrl = URL(string:  Network.ASSET_URL + self.orders[indexPath.item].quotation!.product!.images[0].imageUrl){
                    cell.listingIV.af.setImage(withURL: imageUrl, placeholderImage: UIImage(named: "img_placeholder"))
                }
            }else{
                cell.listingIV.image = UIImage(named: "img_placeholder")
            }
            /// Hide Confirm Btn
            if let status = status {
                cell.confirmBtn.isHidden = (status != "PAID")
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
        
    }
}
