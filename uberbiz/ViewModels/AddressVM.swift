//
//  AddressVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 16/02/21.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

class AddressVM {
    static let shared = AddressVM()
    
    let address:PublishSubject<Address> = PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func createAddress(address:Address){
        let url = "/user/address/create"
        let params:[String:Any] = [
            "address_title": address.addressTitle,
            "address": address.fullAddress,
            "district": address.district,
            "phone_number": address.phoneNumber,
            "postal_code": address.postalCode,
            "province_id": address.province!.id,
            "city_id": address.city!.id,
        ]
        
        print(params)
        
        PrivateService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            var address = Address()
                            address.id = json["data"]["id"].intValue
                            self.address.onNext(address)
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
