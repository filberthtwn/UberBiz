//
//  ProductVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

class ProductVM {
    static let shared = ProductVM()
    
    let products:PublishSubject<[Product]> = PublishSubject()
    let product:PublishSubject<Product> = PublishSubject()
    let image:PublishSubject<ProductImage> = PublishSubject()

    let isSuccess:PublishSubject<Bool> = PublishSubject()
//    let isRegisterSuccess:PublishSubject<Bool> = PublishSubject()
//    let isLogoutSuccess:PublishSubject<Bool> = PublishSubject()
    
    let errorMsg:PublishSubject<String?> =  PublishSubject()
    
    func getSellerProducts(sellerId:Int?, paginate:Int){
        let url = "/user/item/seller_read"
        var params:[String:Any] = [
            "paginate": paginate
        ]
        
        if let sellerId = sellerId{
            params["seller_id"] = sellerId
        }
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(ProductResp.self, from: try json["data"].rawData())
                            self.products.onNext(response.products)
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
    
    func getBuyerProducts(sellerId:Int?, subCategoryId: Int?, productName:String?, paginate:Int){
        let url = "/user/item/buyer_read"
        var params:[String:Any] = [
            "paginate": paginate
        ]
        
        if let sellerId = sellerId{
            params["seller_id"] = sellerId
        }
        
        if let subCategoryId = subCategoryId{
            params["item_sub_category_id"] = subCategoryId
        }
        
        if let productName = productName{
            params["search"] = productName
        }
                        
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(ProductResp.self, from: try json["data"].rawData())
                            self.products.onNext(response.products)
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
    
    func getSellerProductDetail(product:Product){
        let url = "/user/item/seller_read"
        let params:[String:Any] = [
            "item_id": product.id
        ]
        PrivateService.shared.get(url: url, params: params) { (status, data, error) -> (Void) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(Product.self, from: try json["data"].rawData())
                            self.product.onNext(response)
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
    
    
    func createProduct(product:Product){
        let url = "/user/item/create"
        var params:[String:Any] = [
            "item_name": product.itemName,
            "item_description": product.itemDescription,
            "price": product.price,
            "minimum_order": product.minimumOrder,
            "weight": product.weight,
            "unit_id": product.unit.id,
            "item_sub_category_id": product.subcategory.id,
            "warehouse_id": product.warehouse!.id
        ]
        
        for (idx, image) in product.images.enumerated() {
            params["item_images_id[" + String(idx) + "]"] = image.id
        }
        
        
        for (idx, city) in product.shippingCities!.enumerated() {
            params["cities_id[" + String(idx) + "]"] = city.city.id
        }
        
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
    
    func updateProduct(product:Product){
        let url = "/user/item/update"
        var params:[String:Any] = [
            "item_id": product.id,
            "is_accessable": Bool(truncating: NSNumber(value: product.isAccessable)),
            "item_name": product.itemName,
            "item_description": product.itemDescription,
            "price": product.price,
            "minimum_order": product.minimumOrder,
            "weight": product.weight,
            "unit_id": product.unit.id,
            "item_sub_category_id": product.subcategory.id,
            "warehouse_id": product.warehouse!.id
        ]

        for (idx, image) in product.images.enumerated() {
            params["item_images_id[" + String(idx) + "]"] = image.id
        }

        for (idx, itemLocation) in product.shippingCities!.enumerated() {
            params["cities_id[" + String(idx) + "]"] = itemLocation.city.id
        }

        print(params)
                
        PrivateService.shared.patch(url: url, params: params) { (status, data, error) -> (Void) in
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
    
    func uploadProductImage(image:UIImage){
        let url = "/user/item_image/upload"
        
        PrivateService.shared.upload(url: url, images: [image], params: [:], key: "image", completion: { (status, data, error) in
            if status == Network.Status.SUCCESS{
                do{
                    if let data = data{
                        let json = try JSON(data: data)
                        let isSuccess = json["success"].boolValue
                        if isSuccess {
                            let response = try JSONDecoder().decode(ProductImage.self, from: try json["data"].rawData())
                            self.image.onNext(response)
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
    
    func deleteProduct(product:Product){
        let url = "/user/item/delete"
        let params:[String:Any] = [
            "item_id": product.id
        ]
        PrivateService.shared.delete(url: url, params: params) { (status, data, error) -> (Void) in
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
