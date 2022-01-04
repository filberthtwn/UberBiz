//
//  CurrencyHelper.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 28/01/21.
//

import Foundation

class CurrencyHelper {
    static let shared = CurrencyHelper()
    
    func formatCurrency(price:String)->String?{
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        
        guard let priceInt = Int(price) else { return nil }
        return formatter.string(from: priceInt as NSNumber)
    }
}
