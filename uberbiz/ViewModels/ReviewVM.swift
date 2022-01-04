//
//  ReviewVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 21/02/21.
//

import Foundation
import SwiftyJSON
import RxCocoa
import RxSwift

class ReviewVM {
    static let shared = ReviewVM()
    
    let reviews:PublishSubject<[Review]> =  PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func getReview(sellerId:Int, paginate:Int){
        let url = "/user/rating/read"
        let params:[String:Any] = [
            "seller_user_id" : sellerId,
            "paginate" : paginate
        ]

        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(ReviewResp.self, from: json["data"].rawData())
                            self.reviews.onNext(response.reviews)
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
