//
//  Message.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 27/09/21.
//

import Foundation

struct Chat: Codable{
    var type: String = ""
    var senderEmail: String = ""
    var quotationId: Int?
    
    var content: ChatContent = ChatContent()
    
    enum CodingKeys:String, CodingKey {
        case type = "type"
        case quotationId = "quotation_id"
        case content = "content"
        case senderEmail = "sender_email"
    }
}

struct ChatContent: Codable{
    var text: String?
    var path:String?
    var orderId: Int?
    var price: Int?
    var productImage: String?
    var productName: String?
    var requestDescription: String?
    var requestQuotationId: Int?
    
    enum CodingKeys:String, CodingKey {
        case text = "text"
        case path = "path"
        case orderId = "order_id"
        case price = "price"
        case productImage = "product_image"
        case productName = "product_name"
        case requestDescription = "request_description"
        case requestQuotationId = "request_quotation_id"
    }
    
}
