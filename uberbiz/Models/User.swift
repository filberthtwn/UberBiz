//
//  User.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 26/01/21.
//

import Foundation

struct UserRole {
    static let BUYER = "BUYER"
    static let SELLER = "SELLER"
}

struct User: Codable{
    var accessToken:String? = ""
    
    var id:Int?
    var username:String?
    var sellerEmail:String?
    var buyerEmail:String?
    var phoneNumber:String?
    var birthdate:String?
    var storeImageUrl:String?
    var storeName:String?
    var storeDescription:String?
    var npwpImageUrl:String?
    var companyDeedImageUrl:String?
    var isBanned:Int = 0
    var storeProvinceId:Int?
    var storeAddress: Address?
    var isVerified:Int = 0
    var storeBalance: Int?
    var rating:Double?
//    var storeProvinceName:Int?
    var city:City?
    var sellerDocs: SellerDocs?
    
    enum CodingKeys:String, CodingKey {
        case accessToken = "token"
        
        case id = "id"
        case username = "username"
        case sellerEmail = "email"
        case buyerEmail = "email_ubervest"
        case phoneNumber = "phone_number"
        case birthdate = "date_of_birth"
        case storeImageUrl = "store_image"
        case storeName = "store_name"
        case storeDescription = "store_description"
        case isBanned = "is_banned"
        case storeProvinceId = "store_province_id"
        case storeAddress = "store_address"
        case isVerified = "is_verified"
        case storeBalance = "store_balance"
        case rating = "rating"
//        case storeProvinceName = "store_province"
        case city = "store_city"
        case sellerDocs = "seller_document"
    }
}

struct SellerDocs: Codable{
    var npwpImageUrl: String?
    var deedImageUrl: String?
    var status: Status = Status()
    
    enum CodingKeys: String, CodingKey {
        case npwpImageUrl = "npwp"
        case deedImageUrl = "deed"
        case status = "status"
    }
}


struct UserResp: Codable{
    var users: [User] = []
    
    enum CodingKeys:String, CodingKey {
        case users = "data"
    }
}
