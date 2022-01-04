//
//  QuotationVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 16/02/21.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

class QuotationVM {
    static let shared = QuotationVM()
    
    let quotationResp:PublishSubject<QuotationResp> =  PublishSubject()
    let quotation:PublishSubject<Quotation> = PublishSubject()

    let isSuccess:PublishSubject<Bool> =  PublishSubject()
    let successMsg:PublishSubject<String?> =  PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func createQuotation(quotation: Quotation, shippingAddressId: Int){
        let url = "/user/quotation/create"
        var params:[String:Any] = [
            "item_id": quotation.product!.id,
            "buyer_address_id": shippingAddressId,
            "description": quotation.description!,
            "item_price": quotation.price!,
            "quantity": quotation.quantity!,
        ]
        
        if let shippingName = quotation.shippingName{
            params["shipping_name"] = shippingName
        }
        
        if let shippingCost = quotation.shippingCost{
            params["shipping_cost"] = shippingCost
        }
        
        if let shippingTimeEstimation = quotation.shippingTimeEstimation{
            params["delivery_estimate"] = shippingTimeEstimation
        }
        
        print(params)
        
        PrivateService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(QuotationResp.self, from: json["data"].rawData())
                            self.quotationResp.onNext(response)
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
    
    func getQuotationDetail(quotationId: Int){
        let url = "/user/quotation/read"
        let params:[String:Any] = [
            "quotation_id": quotationId
        ]
        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(Quotation.self, from: json["data"].rawData())
                            self.quotation.onNext(response)
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
