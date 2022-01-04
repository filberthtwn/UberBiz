//
//  WithdrawVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 07/03/21.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON

class WithdrawVM {
    static let shared = WithdrawVM()
    
    let isSuccess:PublishSubject<Bool> =  PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func createWithdraw(amount:String, bankName:String, bankNumber:String, message:String){
        let url = "/user/withdraw/create"
        let params:[String:Any] = [
            "amount":amount,
            "bank_name": bankName,
            "account_number": bankNumber,
            "message": message
        ]
        
        print(params)
        
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
}
