//
//  Banner.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 17/02/21.
//

import Foundation

struct Banner: Codable {
    var id:Int = -1
    var imageUrl:String = ""
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case imageUrl = "image"
    }
}

struct BannerResp: Codable {
    var banners:[Banner] = []
    
    enum CodingKeys:String, CodingKey {
        case banners = "data"
    }
}
