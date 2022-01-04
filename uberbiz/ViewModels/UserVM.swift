//
//  UserVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 26/01/21.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON


class UserVM {
    
    static let shared = UserVM()
    
    let isSuccess:PublishSubject<Bool> = PublishSubject()
    let isLoginSuccess:PublishSubject<Bool> = PublishSubject()
    let isRegisterSuccess:PublishSubject<Bool> = PublishSubject()
    let isLogoutSuccess:PublishSubject<Bool> = PublishSubject()
    
    let user:PublishSubject<User> = PublishSubject()
    let users:PublishSubject<[User]> = PublishSubject()
    let imageUrl:PublishSubject<String> = PublishSubject()
    let provinces:PublishSubject<[Province]> = PublishSubject()
    let cities:PublishSubject<[City]> = PublishSubject()
    let banners:PublishSubject<[Banner]> = PublishSubject()

    let message:PublishSubject<String> = PublishSubject()
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func login(email:String, password:String){
        let url = "/user/login"
        let params:[String:Any] = [
            "email": email,
            "password": password,
            "tokenFCM": "123",
        ]
                        
        PublicService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        
                        if isSuccess {
                            do {
                                var user = User()
                                user.accessToken = json["data"]["token"].stringValue
                                let encodedUser = try JSONEncoder().encode(user)
                                UserDefaultHelper.shared.setupUser(data: encodedUser)
                                
                                self.isLoginSuccess.onNext(true)
                                
                            } catch (let error) {
                                self.errorMsg.onNext(error.localizedDescription)
                            }
                        }else{
                            let message = json["message"].stringValue
                            self.errorMsg.onNext(message)
                        }
                    }
                }catch (let error){
                    self.errorMsg.onNext(error.localizedDescription)
                }
            }else{
                self.errorMsg.onNext(error)
            }
        }
    }
    
    func linkAccount(email:String, password:String){
        let url = "/user/profile/link_with_ubervest"
        let params:[String:Any] = [
            "email": email,
            "password": password,
        ]
                        
        PrivateService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.isLoginSuccess.onNext(true)
                        }else{
                            let message = json["message"].stringValue
                            self.errorMsg.onNext(message)
                        }
                    }
                }catch (let error){
                    self.errorMsg.onNext(error.localizedDescription)
                }
            }else{
                self.errorMsg.onNext(error)
            }
        }
    }
    
    func registerSeller(storeName:String, email:String, password:String){
        let url = "/user/register"
        let params:[String:Any] = [
            "store_name": storeName,
            "email": email,
            "password": password,
        ]
                        
        PublicService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.isRegisterSuccess.onNext(true)
                        }else{
                            let message = json["message"].stringValue
                            self.errorMsg.onNext(message)
                        }
                    }
                }catch (let error){
                    self.errorMsg.onNext(error.localizedDescription)
                }
            }else{
                self.errorMsg.onNext(error)
            }
        }
    }
    
    func forgotPassword(email:String){
        let url = "/user/forgot_password"
        let params:[String:Any] = [
            "email": email
        ]
                        
        PublicService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
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
    
    func getUserDetail(){
        let url = "/user/profile/details"
        let params:[String:Any] = [:]
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(User.self, from: try json["data"].rawData())
                            self.user.onNext(response)
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
    
    func updateUser(user:User){
        let url = "/user/profile/update_store"
        var params:[String:Any] = [
            "store_name": user.storeName!,
            "store_description": user.storeDescription!,
        ]
        
        if let storeImageUrl = user.storeImageUrl{
            params["store_image"] = storeImageUrl
        }
        
        if let storeAddress = user.storeAddress{
            params["store_address_id"] = storeAddress.id
        }
        
        if let npwpImageUrl = user.npwpImageUrl{
            params["npwp"] = npwpImageUrl
        }
        
        if let companyDeedImageUrl = user.companyDeedImageUrl{
            params["deed"] = companyDeedImageUrl
        }
        
        print(params)
                        
        PrivateService.shared.patch(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.message.onNext(json["message"].stringValue)
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
    
    func uploadProfileImage(image:UIImage){
        let url = "/user/profile/upload_store_image"
        
        PrivateService.shared.upload(url: url, images: [image], params: [:], key: "image", completion: { (status, data, error) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.imageUrl.onNext(json["data"].stringValue)
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
    
    func uploadSellerDocument(image:UIImage, type:String){
        let url = "/user/seller_document/upload"
        let params = [
            "type": type
        ]
        print(params)
        
        PrivateService.shared.upload(url: url, images: [image], params: params, key: "image", completion: { (status, data, error) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.imageUrl.onNext(json["data"].stringValue)
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
    
    func getAllStore(companyName:String?, subCategory:SubCategory?, city:City?){
        let url = "/user/store/read"
        var params:[String:Any] = [:]
        
        if let companyName = companyName{
            params["search"] = companyName
        }
        params["item_sub_category_id"] = subCategory!.id
        params["cities_id[0]"] = city!.id
        params["paginate"] = 100
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(UserResp.self, from: try json["data"].rawData())
                            self.users.onNext(response.users)
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
    
    func getProvinces(){
        let url = "/province_list"
        let params:[String:Any] = [:]
                        
        PublicService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(ProvinceResp.self, from: data)
                            self.provinces.onNext(response.provinces)
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
    
    func getCities(province:Province?){
        let url = "/city_list"
        var params:[String:Any] = [:]
        
        if let province = province{
            params["province_id"] = province.id
        }
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(CityResp.self, from: data)
                            self.cities.onNext(response.cities)
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
    
    func getBanners(){
        let url = "/user/banner/read"
        let params:[String:Any] = [:]
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(BannerResp.self, from: data)
                            self.banners.onNext(response.banners)
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
    
    func logout(){
        let url = "/user/profile/logout"
        let params:[String:Any] = [:]
                        
        PrivateService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            self.isLogoutSuccess.onNext(true)
                        }else{
                            let message = json["message"].stringValue
                            self.errorMsg.onNext(message)
                        }
                    }
                }catch (let error){
                    self.errorMsg.onNext(error.localizedDescription)
                }
            }else{
                self.errorMsg.onNext(error)
            }
        }
    }
    
}
