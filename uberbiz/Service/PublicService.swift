//
//  PublicService.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 26/01/21.
//

import Foundation
import Alamofire
import SwiftyJSON

class PublicService {
    static let shared = PublicService()
    private var maxRetryCount = 1
    private var loadCount = 0
    
    func post(url:String, params:[String:Any], completion:@escaping(_ status:String, _ data:Data?,_ error:String?)->Void){
        
        if NetworkReachabilityManager()?.isReachable ?? false{
            let stringURL = String(format: "%@%@", arguments: [Network.BASE_URL, url])
            AF.request(stringURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseData { (response) in
                
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
                }catch(let error){
                    completion(Network.Status.FAILURE, nil, error.localizedDescription)
                }
            }
        }else{
            DispatchQueue.main.async {
                completion(Network.Status.FAILURE, nil, Error.NO_INTERNET_CONNECTION)
            }
        }
    }
    
    func get(url:String, params:[String:Any], completion:@escaping(_ status:String, _ data:Data?,_ error:String?)->Void){
        if NetworkReachabilityManager()?.isReachable ?? false{
            let stringURL = String(format: "%@%@", arguments: [Network.BASE_URL, url])
            AF.request(stringURL, method: .get, parameters: params, headers: nil).responseJSON { (response) in
                
                guard let request = response.request else {return}
                
                print(request)
                print(response.result)
                
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
            }
        }else{
            DispatchQueue.main.async {
                completion(Network.Status.FAILURE, nil, Error.NO_INTERNET_CONNECTION)
            }
        }
    }
}


