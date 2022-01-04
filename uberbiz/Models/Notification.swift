//
//  Notification.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 20/02/21.
//

import Foundation

struct Notification: Codable {
    var title: String = ""
    var message:String = ""
    var isReaded: Bool = false
    var createdAt: String = ""
    
    enum CodingKeys:String, CodingKey {
        case title = "title"
        case message = "message"
        case isReaded = "is_read"
        case createdAt = "created_at"
    }
}
