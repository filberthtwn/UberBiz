//
//  OrderTableCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 07/01/21.
//

import UIKit

protocol OrderProtocol {
    func didOrderTapped(order:Order)
    func didConfirmAction()
}

class OrderTableCollectionViewCell: UICollectionViewCell {

    @IBOutlet var orderTableView: UITableView!
    
    var delegate: OrderProtocol?
    var orders:[Order] = []{
        didSet{
            self.orderTableView.reloadData()
        }
    }
    var status: String = ""
    var isDataLoaded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    private func setupViews(){
        self.orderTableView.delegate = self
        self.orderTableView.dataSource = self
        self.orderTableView.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.orderTableView.register(UINib(nibName: "UnPaidOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "UnPaidOrderCell")
        self.orderTableView.register(UINib(nibName: "DefaultOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultOrderCell")
    }
    
    
}

extension OrderTableCollectionViewCell: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return self.orders.count
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isDataLoaded{
            self.delegate?.didOrderTapped(order: self.orders[indexPath.item])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded{
            if (self.status == "UNPAID"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "UnPaidOrderCell", for: indexPath) as! UnPaidOrderTableViewCell
                if let imageURL = URL(string: Network.ASSET_URL + self.orders[indexPath.item].quotation!.product!.images[0].imageUrl){
                    cell.listingIV.af.setImage(withURL: imageURL, placeholderImage: UIImage(named: "img_placeholder"))
                }
                cell.listingNameL.text = self.orders[indexPath.item].quotation!.product!.itemName
                cell.listingPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: self.orders[indexPath.item].quotation!.product!.price)! + "/ " + self.orders[indexPath.item].quotation!.product!.unit.unitName
                cell.listingQuantityL.text = String(self.orders[indexPath.item].quantity) + " " + self.orders[indexPath.item].quotation!.product!.unit.unitName
                cell.listingTotalL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: String(self.orders[indexPath.item].pricePerItem))!
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultOrderCell", for: indexPath) as! DefaultOrderTableViewCell
                if self.orders[indexPath.item].quotation!.product!.images.count > 0{
                    if let imageURL = URL(string: Network.ASSET_URL + self.orders[indexPath.item].quotation!.product!.images[0].imageUrl){
                        cell.listingIV.af.setImage(withURL: imageURL, placeholderImage: UIImage(named: "img_placeholder"))
                    }
                }else{
                    cell.listingIV.image = UIImage(named: "img_placeholder")
                }
                cell.listingNameL.text = self.orders[indexPath.item].quotation!.product!.itemName
                cell.listingPriceL.text = "Rp" + CurrencyHelper.shared.formatCurrency(price: self.orders[indexPath.item].quotation!.product!.price)! + "/ " + self.orders[indexPath.item].quotation!.product!.unit.unitName
                cell.listingQuantityL.text = String(self.orders[indexPath.item].quantity) + " " + self.orders[indexPath.item].quotation!.product!.unit.unitName
                
                /// Hide Confirm Btn
                cell.confirmBtn.isHidden = true
                
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
    }
}
