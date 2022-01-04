//
//  WishlistVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 29/01/21.
//

import Foundation
import RxCocoa
import RxSwift
import SwiftyJSON

class WishlistVM {
    static let shared = WishlistVM()
    
    let wishlists:PublishSubject<[Wishlist]> = PublishSubject()
    let wishlist:PublishSubject<Wishlist> = PublishSubject()
    
    let isSuccess:PublishSubject<Bool> =  PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func getWishlists(){
        let url = "/user/wishlist/read"
        let params:[String:Any] = [:]
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(WishlistResp.self, from: try json["data"].rawData())
                            self.wishlists.onNext(response.wishlists)
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
    
    func createWishlist(product: Product){
        let url = "/user/wishlist/create"
        let params:[String:Any] = [
            "item_id": product.id
        ]
                        
        PrivateService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
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
    
    func deleteWishlist(product: Product){
        let url = "/user/wishlist/delete"
        let params:[String:Any] = [
            "item_id": product.id
        ]
        print(params)
        PrivateService.shared.delete(url: url, params: params) { (status, data, error) -> (Void) in
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
}
