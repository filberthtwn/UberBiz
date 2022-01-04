//
//  CityVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 02/02/21.
//

import Foundation
import RxSwift
import RxCocoa

class CityVM {
    static let shared = CityVM()
    
    let cities:PublishSubject<[City]> = PublishSubject()
//    let subCategories:PublishSubject<[SubCategory]> = PublishSubject()

    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
//    func getUnits(){
//        let url = "/user/unit/read"
//        let params:[String:Any] = [:]
//                        
//        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
//            if status == Network.Status.SUCCESS{
//                do{
//                    if let data = data{
//                        let json = try JSON(data: data)
//                        let isSuccess = json["success"].boolValue
//                        if isSuccess {
//                            let response = try JSONDecoder().decode(UnitResp.self, from: data)
//                            self.units.onNext(response.units)
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
}
