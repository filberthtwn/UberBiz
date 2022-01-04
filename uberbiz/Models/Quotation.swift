//
//  Quotation.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 03/02/21.
//

import Foundation

struct Quotation: Codable {
    var id:Int = -1
    var product: Product?
    var description: String?
    var price: Int?
    var quantity: String?
    var buyer: User?
    var shippingAddress: Address?
    var shippingName: String?
    var shippingCost: Int?
    var shippingTimeEstimation: Int?
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case product = "item"
        case description = "description"
        case price = "item_price"
        case quantity = "quantity"
        case buyer = "buyer_user"
        case shippingCost = "shipping_cost"
        case shippingTimeEstimation = "delivery_estimate"
        case shippingAddress = "buyer_address"
    }
}

struct QuotationResp: Codable {
    var order: Order?
    var quotation: Quotation?
    
    enum CodingKeys:String, CodingKey {
        case order = "order"
        case quotation = "quotation"
    }
}
