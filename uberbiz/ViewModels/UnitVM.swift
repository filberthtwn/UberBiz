//
//  UnitVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 01/02/21.
//

import Foundation
import RxCocoa
import RxSwift
import SwiftyJSON

class UnitVM {
    static let shared = UnitVM()
    
    let units:PublishSubject<[Unit]> = PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func getUnits(){
        let url = "/user/unit/read"
        let params:[String:Any] = [:]
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(UnitResp.self, from: data)
                            self.units.onNext(response.units)
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
