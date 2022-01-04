//
//  Request.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 15/02/21.
//

import Foundation

struct RequestQuotation: Codable {
    var id:Int = -1
    var title:String = ""
    var description:String = ""
    var subcategory:SubCategory?
    var unit:Unit?
    var quantity:Int = 0
    var deliveryAddress: Address?
    var deliveryAddressId: Int?
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case title = "title"
        case description = "description"
        case subcategory = "item_sub_category"
        case unit = "unit"
        case deliveryAddress = "delivery_address"
        case deliveryAddressId = "delivery_address_id"
        case quantity = "quantity"
    }
}
