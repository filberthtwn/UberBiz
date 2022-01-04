//
//  Order.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 03/02/21.
//

import Foundation

struct Order: Codable {
    var id:Int = -1
    var quantity:Int = 0
    var pricePerItem:Int = 0
    var shippingName:String?
    var shippingCost:Int?
    var insurance: Int?
    var adminFee: Int?
    var buyerUser: User?
    var buyerAddress: Address?
    var shippingEstimationTime: Int?
    var status:Status?
    var createdAt:String = ""
    var quotation:Quotation?
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case quantity = "quantity"
        case pricePerItem = "item_price"
        case shippingName = "shipping_name"
        case shippingCost = "shipping_cost"
        case insurance = "insurance"
        case adminFee = "admin_fee"
        case status = "status"
        case quotation = "quotation"
        case buyerAddress = "buyer_address"
        case shippingEstimationTime = "delivery_estimate"
        case createdAt = "created_at"
    }
}

struct OrderResp: Codable{
    var orders:[Order] = []
    enum CodingKeys:String, CodingKey {
        case orders = "data"
    }
}
