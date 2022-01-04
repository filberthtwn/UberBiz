//
//  Status.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 04/02/21.
//

import Foundation

struct Status: Codable {
    var id: Int = -1
    var type: String = ""
    var statusName: String = ""
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case type = "type"
        case statusName = "status_name"
    }
}
