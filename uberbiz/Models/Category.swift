//
//  Category.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import Foundation

class Category: Codable {
    var id:Int = -1
    var categoryName:String = ""
    var categoryImageUrl:String?
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case categoryName = "item_category_name"
        case categoryImageUrl = "item_category_image"
    }
}

class CategoryResp: Codable {
    var categories:[Category] = []
    
    enum CodingKeys:String, CodingKey {
        case categories = "data"
    }
}

class SubCategory: Codable {
    var id:Int = -1
    var subCategoryName:String = ""
    var subCategoryImageUrl:String?
    
    enum CodingKeys:String, CodingKey {
        case id = "id"
        case subCategoryName = "item_sub_category_name"
        case subCategoryImageUrl = "item_sub_category_image"
    }
}

class SubCategoryResp: Codable {
    var subCategories:[SubCategory] = []
    
    enum CodingKeys:String, CodingKey {
        case subCategories = "data"
    }
}

