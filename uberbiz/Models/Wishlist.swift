//
//  Wishlist.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 29/01/21.
//

import Foundation

struct Wishlist: Codable {
    var id:Int = -1
    var product:Product?
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case product = "item"
    }
}

struct WishlistResp: Codable{
    var wishlists:[Wishlist] = []
    enum CodingKeys:String, CodingKey {
        case wishlists = "data"
    }
}
