//
//  Unit.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import Foundation

class Unit: Codable {
    var id:Int = -1
    var unitName:String = ""
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case unitName = "unit_name"
    }
}

class UnitResp: Codable {
    var units:[Unit] = []
    
    enum CodingKeys:String, CodingKey {
        case units = "data"
    }
}
