//
//  Dialog.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 27/09/21.
//

import Foundation

struct Dialog: Codable {
    var id: String = ""
    var occupants: [Occupant] = []
    var messages: [Chat] = []
    
    enum CodingKeys:String, CodingKey {
        case occupants = "occupants"
        case messages = "messages"
    }
}
