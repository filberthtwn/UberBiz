//
//  Occupant.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 27/09/21.
//

import Foundation

struct Occupant: Codable {
    var email: String = ""
    var name: String = ""
    
    enum CodingKeys:String, CodingKey {
        case email = "email"
        case name = "name"
    }
}
