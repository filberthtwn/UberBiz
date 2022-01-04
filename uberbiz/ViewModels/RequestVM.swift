//
//  RequestVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 15/02/21.
//

import Foundation
import RxSwift
import RxRelay
import SwiftyJSON

class RequestVM {
    static let shared = RequestVM()
    
    let isSuccess:PublishSubject<Bool> =  PublishSubject()
    let requestQuotation:PublishSubject<RequestQuotation> =  PublishSubject()

    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func createRequest(requestQuotation:RequestQuotation, selectedSellers:[User]){
        let url = "/user/request_quotation/create"
        var params:[String:Any] = [
            "title": requestQuotation.title,
            "description": requestQuotation.description,
            "item_sub_category_id": requestQuotation.subcategory!.id,
            "unit_id": requestQuotation.unit!.id,
            "quantity": requestQuotation.quantity,
            "delivery_address_id": requestQuotation.deliveryAddress!.id
        ]
        
        for (idx, selectedSeller) in selectedSellers.enumerated() {
            params["seller_ids[\(idx)]"] = selectedSeller.id!
        }
        
        PrivateService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(RequestQuotation.self, from: json["data"]["request"].rawData())
                            self.requestQuotation.onNext(response)
//                            self.requestId.onNext(true)
                        }else{
                            let message = json["message"].stringValue
                            self.errorMsg.onNext(message)
                        }
                    }
                }catch (let error){
                    print("ERROR: \(error)")
                    self.errorMsg.onNext(error.localizedDescription)
                }
            }else{
                self.errorMsg.onNext(error)
            }
        }
    }
    
    func getRequestDetail(id: Int){
        let url = "/user/request_quotation/read"
        let params = [
            "request_quotation_id" : id
        ]
        PrivateService.shared.get(url: url, params: params) { status, data, error in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(RequestQuotation.self, from: json["data"].rawData())
                            self.requestQuotation.onNext(response)
                        }else{
                            let message = json["message"].stringValue
                            self.errorMsg.onNext(message)
                        }
                    }
                }catch (let error){
                    print("ERROR: \(error)")
                    self.errorMsg.onNext(error.localizedDescription)
                }
            }else{
                self.errorMsg.onNext(error)
            }
        }
    }
}
