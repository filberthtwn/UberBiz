//
//  Notification.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 20/02/21.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

class NotificationVM {
    static let shared  = NotificationVM()
    
    let notifications:PublishSubject<[Notification]> =  PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func getNotifications(role:String, paginate:Int){
        let url = "/user/notification/read"
        let params:[String:Any] = [
            "which_user" : role,
            "paginate" : paginate
        ]

        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode([Notification].self, from: json["data"]["data"].rawData())
                            self.notifications.onNext(response)
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
