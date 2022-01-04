//
//  MessengerSectionCollectionViewCell.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 18/02/21.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON

class MessengerSectionCollectionViewCell: UICollectionViewCell {

    @IBOutlet var messengerTableV: UITableView!
    @IBOutlet var emptyStateL: UILabel!
    
    var dialogs:[Dialog] = []{
        didSet{
            if dialogs.count == 0 && isDataLoaded{
                emptyStateL.isHidden = false
            }else{
                emptyStateL.isHidden = true
            }
            messengerTableV.reloadData()
        }
    }
    
    var isDataLoaded = false
    
    var delegate: MessengerProtocol?
    var selectedRole: String = Role.BUYER
    
    private var disposeBag:DisposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.messengerTableV.register(UINib(nibName: "ShimmerMyProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ShimmerCell")
        self.messengerTableV.register(UINib(nibName: "MessengerTableViewCell", bundle: nil), forCellReuseIdentifier: "MessengerCell")
        
        self.messengerTableV.delegate = self
        self.messengerTableV.dataSource = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.emptyStateL.isHidden = true
    }

}

extension MessengerSectionCollectionViewCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDataLoaded{
            return dialogs.count
        }else{
            return 10
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isDataLoaded{
            self.delegate?.didSelect(index: indexPath.item)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isDataLoaded{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessengerCell", for: indexPath) as! MessengerTableViewCell
            let user = UserDefaultHelper.shared.getUser()!
            let email = (selectedRole == UserRole.BUYER) ? user.buyerEmail : user.sellerEmail
            let opponent = dialogs[indexPath.item].occupants.first(where: { $0.email != email })
            
            guard let opponent = opponent else { return cell }
            cell.nameL.text = opponent.name
            cell.messageL.text = "Start Chat Now!"
            
            if let lastMessage = dialogs[indexPath.item].messages.first {
                switch lastMessage.type {
                    case MessageType.TEXT:
                        cell.messageL.text = lastMessage.content.text ?? "-"
                    case MessageType.IMAGE:
                        cell.messageL.text = "Image"
                    case MessageType.REQUEST_FOR_QUOTATION:
                        cell.messageL.text = "Request for Quotation"
                    default:
                        break
                }
            }

            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
            return cell
        }
    }
}
