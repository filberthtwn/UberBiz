//
//  Address.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/02/21.
//

import Foundation

struct Address: Codable {
    var id: Int = -1
    var addressTitle: String = ""
    var fullAddress: String = ""
    var postalCode: String = ""
    var phoneNumber: String = ""
    var city: City?
    var province: Province?
    var district: String = ""

    enum CodingKeys:String, CodingKey {
        case id = "id"
        case addressTitle = "address_title"
        case fullAddress = "address"
        case postalCode = "postal_code"
        case phoneNumber = "phone_number"
        case city = "city"
        case province = "province"
        case district = "district"
    }
}
