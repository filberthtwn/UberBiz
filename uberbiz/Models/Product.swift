//
//  Product.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import Foundation

struct Product: Codable{
    
    var id:Int = -1
    var itemName:String = ""
    var itemDescription:String = ""
    var price:String = "0"
    var deletedAt:String?
    var minimumOrder:Int = 0
    var isAccessable:Bool = false
    var weight:Int = 0
    var unit:Unit = Unit()
    var seller:User?
    var address:Address?
    var images:[ProductImage] = []
    var subcategory:SubCategory = SubCategory()
    var warehouse:Address?
    var isWishlisted:Bool? = false
    
    var shippingCities:[ItemLocation]?
    
    enum CodingKeys:String, CodingKey {        
        case id = "id"
        case itemName = "item_name"
        case itemDescription = "item_description"
        case price = "price"
        case deletedAt = "deleted_at"
        case minimumOrder = "minimum_order"
        case isAccessable = "is_accessable"
        case weight = "weight"
        case unit = "unit"
        case seller = "seller"
        case address = "address"
        case images = "item_images"
        case subcategory = "item_sub_category"
        case warehouse = "warehouse"
        case shippingCities = "item_locations"
        case isWishlisted = "is_wishlisted"
    }
}

struct ProductImage: Codable{
    var id:Int = -1
    var imageUrl:String = ""
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case imageUrl = "image"
    }
}

struct ProductResp: Codable{
    var products:[Product] = []
    enum CodingKeys:String, CodingKey {
        case products = "data"
    }
}



