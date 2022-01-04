//
//  Review.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 23/02/21.
//

import Foundation

struct Review: Codable {
    var rate: Double = 0
    var description:String?
    var user: User?
    
    enum CodingKeys:String, CodingKey {
        case rate = "rate"
        case description = "description"
        case user = "user"
    }
}

struct ReviewResp: Codable {
    var reviews:[Review] = []
    
    enum CodingKeys:String, CodingKey {
        case reviews = "data"
    }
}
