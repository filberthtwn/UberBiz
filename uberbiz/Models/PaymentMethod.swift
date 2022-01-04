//
//  PaymentMethod.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 06/03/21.
//

import Foundation

struct PaymentMethod: Codable {
    
    var channelCategory:String = ""
    var channelCode:String = ""
    
    enum CodingKeys:String, CodingKey {
        case channelCategory = "channel_category"
        case channelCode = "channel_code"
    }
}

struct PaymentMethodResp: Codable {

    var paymentMethods:[PaymentMethod] = []
    
    enum CodingKeys:String, CodingKey {
        case paymentMethods = "data"
    }
}
