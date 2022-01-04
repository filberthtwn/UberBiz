//
//  OrderVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 03/02/21.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON

class OrderVM{
    static let shared = OrderVM()
    
    let orders:PublishSubject<[Order]> = PublishSubject()
    let paymentMethods:PublishSubject<[PaymentMethod]> = PublishSubject()
    let paymentReceiptUrl: PublishSubject<String> = PublishSubject()
    let isSuccess: PublishSubject<Bool> = PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
//    func getMyOrder(status:String){
//        let url = "/user/order/read"
//        let params:[String:Any] = [
//            "status_name" : status
//        ]
//
//        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
//            if status == Network.Status.SUCCESS{
//                do{
//                    if let data = data{
//                        let json = try JSON(data: data)
//                        let isSuccess = json["success"].boolValue
//                        if isSuccess {
////                            let response = try JSONDecoder().decode(UnitResp.self, from: data)
//                            self.orders.onNext([])
//                        }else{
//                            let message = json["message"].stringValue
//                            self.errorMsg.onNext(message)
//                        }
//                    }
//                }catch (let error){
//                    print("ERROR: \(error)")
//                    self.errorMsg.onNext(error.localizedDescription)
//                }
//            }else{
//                self.errorMsg.onNext(error)
//            }
//        }
//    }
    
    func getOrders(status:String, isSeller: Bool){
        let url = "/user/order/read"
        let params:[String:Any] = [
            "status_name": status,
            "is_seller": isSeller
        ]

        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(OrderResp.self, from: json["data"].rawData())
                            self.orders.onNext(response.orders)
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
    
    func getPaymentMethods(){
        let url = "/user/xendit/payment_method"
        let params:[String:Any] = [:]

        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(PaymentMethodResp.self, from: data)
                            self.paymentMethods.onNext(response.paymentMethods)
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
    
    func checkoutOrder(order:Order, paymentCode: String, paymentCategory: String, isInsurance: Bool){
        let url = "/user/order/checkout"
        var params:[String:Any] = [
            "order_id" : order.id,
            "payment_channel_code": paymentCode,
            "payment_channel_category": paymentCategory,
            "insurance": isInsurance
        ]
        
        if let shippingName = order.shippingName{
            params["shipping_name"] = shippingName
        }
        
        if let shippingCost = order.shippingCost{
            params["shipping_cost"] = shippingCost
        }
        
        if let shippingTime = order.shippingEstimationTime{
            params["delivery_estimate"] = shippingTime
        }
        
        print(params)

        PrivateService.shared.patch(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.isSuccess.onNext(true)
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
    
    func sendPayementReceipt(imageUrl: String, order: Order){
        let url = "/user/order/input_evidence_of_transfer"
        let params:[String:Any] = [
            "payment_receipt": imageUrl,
            "order_id": order.id
        ]
        
        PrivateService.shared.patch(url: url, params: params) { (status, data, error) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.isSuccess.onNext(true)
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
        
//        PrivateService.shared.upload(url: url, images: [image], params: [:], key: "image", completion: { (status, data, error) in
//            if status == Network.Status.SUCCESS{
//                do{
//                    if let data = data{
//                        let json = try JSON(data: data)
//                        let isSuccess = json["success"].boolValue
//                        if isSuccess {
//                            self.paymentReceiptUrl.onNext(json["data"].stringValue)
//                        }else{
//                            let message = json["message"].stringValue
//                            self.errorMsg.onNext(message)
//                        }
//                    }
//                }catch (let error){
//                    print("ERROR: \(error)")
//                    self.errorMsg.onNext(error.localizedDescription)
//                }
//            }else{
//                self.errorMsg.onNext(error)
//            }
//        })
    }
    
    func uploadPayementReceipt(image: UIImage){
        let url = "/user/order/upload_payment_receipt"
        
        PrivateService.shared.upload(url: url, images: [image], params: [:], key: "image", completion: { (status, data, error) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.paymentReceiptUrl.onNext(json["data"].stringValue)
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
        })
    }
}
