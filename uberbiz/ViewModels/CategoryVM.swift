//
//  CategoryVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import Foundation
import SwiftyJSON
import RxCocoa
import RxSwift

class CategoryVM {
    static let shared = CategoryVM()
    
    let categories:PublishSubject<[Category]> = PublishSubject()
    let subCategories:PublishSubject<[SubCategory]> = PublishSubject()

    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func getCategories(){
        let url = "/user/item_category/read"
        let params:[String:Any] = [:]
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(CategoryResp.self, from: data)
                            self.categories.onNext(response.categories)
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
    
    func getSubCategories(categoryId:Int){
        let url = "/user/item_sub_category/read"
        let params:[String:Any] = [
            "item_category_id": categoryId
        ]
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(SubCategoryResp.self, from: data)
                            self.subCategories.onNext(response.subCategories)
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
