//
//  Province.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/02/21.
//

import Foundation

class Province: Codable {
    var id:Int = -1
    var provinceName:String = ""
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case provinceName = "province_name"
    }
}

class ProvinceResp: Codable {
    var provinces:[Province] = []
    
    enum CodingKeys:String, CodingKey {
        case provinces = "data"
    }
}

