//
//  City.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import Foundation

class City: Codable {
    var id:Int = -1
    var cityName:String = ""
    var provinceId:Int = -1
    var type:String = ""
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case cityName = "city_name"
        case provinceId = "province_id"
        case type = "type"
    }
}

class CityResp: Codable {
    var cities:[City] = []
    
    enum CodingKeys:String, CodingKey {
        case cities = "data"
    }
}

class ItemLocation: Codable{
    var id:Int = -1
    var city:City = City()
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case city = "city"
    }
}

