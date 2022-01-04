//
//  PrivateService.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 26/01/21.
//

import Foundation
import Alamofire
import SwiftyJSON

class PrivateService {
    static let shared = PrivateService()
    private var maxRetryCount = 1
    private var loadCount = 0
    
    func post(url:String, params:[String:Any], completion:@escaping(_ status:String, _ data:Data?,_ error:String?)->Void){
        if NetworkReachabilityManager()?.isReachable ?? false{
            if let currentUser = UserDefaultHelper.shared.getUser(){
                let headers: HTTPHeaders = ["Authorization": String.init(format: "Bearer %@", currentUser.accessToken!)]
                let stringURL = String(format: "%@%@", arguments: [Network.BASE_URL, url])
                
                print(stringURL)
                
                AF.request(stringURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseData { (response) in
                    
                    do{
                        let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! Dictionary<String, AnyObject>
                        
                        guard let request = response.request else {return}
                        
                        print(request)
                        print(String(data: request.httpBody!, encoding: .utf8)!)
                        
                        // MARK: PRETTY PRINT JSON RESPONSE
                        let jsonData = try JSONSerialization.data(withJSONObject: parsedData, options: .prettyPrinted)
                        print(String(decoding: jsonData, as: UTF8.self))
                        
                        switch response.result{
                        case .success:
                            completion(Network.Status.SUCCESS, response.data, nil)
                            
                        case .failure(let error):
                            print(error)
                            if error.isSessionTaskError{
                                self.loadCount = self.loadCount + 1
                                if self.loadCount < 5{
                                    self.post(url: url, params: params, completion: completion)
                                }else{
                                    completion(Network.Status.FAILURE, nil, error.localizedDescription)
                                }
                            }else{
                                completion(Network.Status.FAILURE, nil, error.localizedDescription)
                            }
                        }
                        
                    }catch (let error){
                        print(error)
                        completion(Network.Status.FAILURE, nil, error.localizedDescription)
                    }
                }
            }else{
                completion(Network.Status.FAILURE, nil, Error.UNAUTHORIZED)
            }
        }else{
            DispatchQueue.main.async {
                completion(Network.Status.FAILURE, nil, Error.NO_INTERNET_CONNECTION)
            }
        }
    }
    
    func patch(url:String, params:[String:Any], completion:@escaping(_ status:String, _ data:Data?,_ error:String?)->Void){
        if NetworkReachabilityManager()?.isReachable ?? false{
            if let currentUser = UserDefaultHelper.shared.getUser(){
                let headers: HTTPHeaders = ["Authorization": String.init(format: "Bearer %@", currentUser.accessToken!)]
                let stringURL = String(format: "%@%@", arguments: [Network.BASE_URL, url])
                
                AF.request(stringURL, method: .patch, parameters: params, encoding: URLEncoding.init(destination: .methodDependent, arrayEncoding: .noBrackets, boolEncoding: .literal), headers: headers) .responseData { (response) in
                    
                    do{
                        let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! Dictionary<String, AnyObject>
                        
                        guard let request = response.request else {return}
                        
                        print(request)
                        print(String(data: request.httpBody!, encoding: .utf8)!)
                        
                        // MARK: PRETTY PRINT JSON RESPONSE
                        let jsonData = try JSONSerialization.data(withJSONObject: parsedData, options: .prettyPrinted)
                        print(String(decoding: jsonData, as: UTF8.self))
                        
                        switch response.result{
                        case .success:
                            completion(Network.Status.SUCCESS, response.data, nil)
                        case .failure(let error):
                            print(error)
                            if error.isSessionTaskError{
                                self.loadCount = self.loadCount + 1
                                if self.loadCount < self.maxRetryCount{
                                    self.post(url: url, params: params, completion: completion)
                                }else{
                                    completion(Network.Status.FAILURE, nil, error.localizedDescription)
                                }
                            }else{
                                completion(Network.Status.FAILURE, nil, error.localizedDescription)
                            }
                        }
                    }catch (let error){
                        print(error)
                        completion(Network.Status.FAILURE, nil, error.localizedDescription)
                    }
                }
            }else{
                // MARK: Logout Process
                UserDefaultHelper.shared.deleteUser()
                
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                UIApplication.shared.keyWindow?.rootViewController?.present(loginVC, animated: true, completion: nil)
                
                completion(Network.Status.FAILURE, nil, Error.UNAUTHORIZED)
            }
        }else {
            DispatchQueue.main.async {
                completion(Network.Status.FAILURE, nil, Error.NO_INTERNET_CONNECTION)
            }
        }
    }
    
    func get(url:String, params:[String:Any], completion:@escaping(_ status:String, _ data:Data?,_ error:String?)->Void){
        if NetworkReachabilityManager()?.isReachable ?? false{
            if let currentUser = UserDefaultHelper.shared.getUser(), let accessToken = currentUser.accessToken{
                let headers: HTTPHeaders = ["Authorization": String.init(format: "Bearer %@", accessToken)]
                let stringURL = String(format: "%@%@", arguments: [Network.BASE_URL, url])
                
                AF.request(stringURL, method: .get, parameters: params ,headers: headers).responseData { (response) in
                    
                    do{
                        let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! Dictionary<String, AnyObject>
                        
                        guard let request = response.request else {return}
                        
                        print(request)
                        
                        // MARK: PRETTY PRINT JSON RESPONSE
                        let jsonData = try JSONSerialization.data(withJSONObject: parsedData, options: .prettyPrinted)
                        print(String(decoding: jsonData, as: UTF8.self))
                        
                        switch response.result{
                        case .success:
                            completion(Network.Status.SUCCESS, response.data, nil)
                        case .failure(let error):
                            print(error)
                            if error.isSessionTaskError{
                                self.loadCount = self.loadCount + 1
                                if self.loadCount <  self.maxRetryCount{
                                    self.get(url: url, params: params, completion: completion)
                                }else{
                                    completion(Network.Status.FAILURE, nil, error.localizedDescription)
                                }
                            }else{
                                completion(Network.Status.FAILURE, nil, error.localizedDescription)
                            }
                        }
                    }catch (let error){
                        print(error)
                        completion(Network.Status.FAILURE, nil, error.localizedDescription)
                    }
                }
            }else{
                // MARK: Logout Process
                
                UserDefaultHelper.shared.deleteUser()
                
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                UIApplication.shared.keyWindow?.rootViewController?.present(loginVC, animated: true, completion: nil)
                
                completion(Network.Status.FAILURE, nil, Error.UNAUTHORIZED)
            }
        }else {
            DispatchQueue.main.async {
                completion(Network.Status.FAILURE, nil, Error.NO_INTERNET_CONNECTION)
            }
        }
    }
    
    func upload(url:String, images:[UIImage?], params:[String:Any], key:String ,completion:@escaping(_ status:String, _ data:Data?,_ error:String?)->Void){
        if NetworkReachabilityManager()?.isReachable ?? false{
            if let currentUser = UserDefaultHelper.shared.getUser(){
                let headers: HTTPHeaders = ["Authorization": String.init(format: "Bearer %@", currentUser.accessToken!)]
                let stringURL = String(format: "%@%@", arguments: [Network.BASE_URL, url])
                print(stringURL)
                
                AF.upload(multipartFormData: { (multipartFromData) in
                    for (_, image) in images.enumerated(){
                        if let image = image {
                            //                        if images.count == 1{
                            multipartFromData.append(image.jpegData(compressionQuality: 0.25)!, withName: key, fileName: "file.jpeg",mimeType: "image/jpeg")
                            //                        }else{
                            //                            multipartFromData.append(image.jpegData(compressionQuality: 0.25)!, withName: key + "[" + String(idx) + "]", fileName: "file.jpeg",mimeType: "image/jpeg")
                            //                        }
                        }
                    }
                    
                    for param in params{
                        multipartFromData.append(Data((param.value as! String).utf8), withName: param.key)
                    }
                    
                }, to: stringURL,
                          usingThreshold: UInt64.init(),
                          method: .post,
                          headers: headers).responseJSON{ response in
                    do{
                        let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! Dictionary<String, AnyObject>
                        
                        guard let request = response.request else {return}
                        
                        print(request)
                        
                        // MARK: PRETTY PRINT JSON RESPONSE
                        let jsonData = try JSONSerialization.data(withJSONObject: parsedData, options: .prettyPrinted)
                        print(String(decoding: jsonData, as: UTF8.self))
                        
                        switch response.result{
                        case .success:
                            completion(Network.Status.SUCCESS, response.data, nil)
                        case .failure(let error):
                            print(error)
                            if error.isSessionTaskError{
                                self.loadCount = self.loadCount + 1
                                if self.loadCount <  self.maxRetryCount{
                                    self.upload(url: url, images: images, params: params, key: key, completion: completion)
                                }else{
                                    completion(Network.Status.FAILURE, nil, error.localizedDescription)
                                }
                            }else{
                                completion(Network.Status.FAILURE, nil, error.localizedDescription)
                            }
                        }
                    }catch (let error){
                        print(error)
                        completion(Network.Status.FAILURE, nil, error.localizedDescription)
                    }
                }
            }else{
                completion(Network.Status.FAILURE, nil, Error.UNAUTHORIZED)
            }
        }else{
            DispatchQueue.main.async {
                completion(Network.Status.FAILURE, nil, Error.NO_INTERNET_CONNECTION)
            }
        }
    }
    
    func delete(url:String, params:[String:Any], completion:@escaping(_ status:String, _ data:Data?,_ error:String?)->Void){
        if NetworkReachabilityManager()?.isReachable ?? false{
            if let currentUser = UserDefaultHelper.shared.getUser(){
                let headers: HTTPHeaders = ["Authorization": String.init(format: "Bearer %@", currentUser.accessToken!)]
                let stringURL = String(format: "%@%@", arguments: [Network.BASE_URL, url])
                
                print(stringURL)
                
                AF.request(stringURL, method: .delete, parameters: params, headers: headers).responseData { (response) in
                    
                    //                print(response.request)
                    //                print(NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue))
                    
                    do{
                        let parsedData = try JSONSerialization.jsonObject(with: response.data!) as! Dictionary<String, AnyObject>
                        
                        guard let request = response.request else {return}
                        
                        print(request)
                        //                    print(String(data: request.httpBody!, encoding: .utf8)!)
                        
                        // MARK: PRETTY PRINT JSON RESPONSE
                        let jsonData = try JSONSerialization.data(withJSONObject: parsedData, options: .prettyPrinted)
                        print(String(decoding: jsonData, as: UTF8.self))
                        
                        switch response.result{
                        case .success:
                            completion(Network.Status.SUCCESS, response.data, nil)
                            
                        case .failure(let error):
                            print(error)
                            if error.isSessionTaskError{
                                self.loadCount = self.loadCount + 1
                                if self.loadCount <  self.maxRetryCount{
                                    self.post(url: url, params: params, completion: completion)
                                }else{
                                    completion(Network.Status.FAILURE, nil, error.localizedDescription)
                                }
                            }else{
                                completion(Network.Status.FAILURE, nil, error.localizedDescription)
                            }
                        }
                        
                    }catch (let error){
                        print(error)
                        completion(Network.Status.FAILURE, nil, error.localizedDescription)
                    }
                }
            }else{
                completion(Network.Status.FAILURE, nil, Error.UNAUTHORIZED)
            }
        }else{
            DispatchQueue.main.async {
                completion(Network.Status.FAILURE, nil, Error.NO_INTERNET_CONNECTION)
            }
        }
    }
}



