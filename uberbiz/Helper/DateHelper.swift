//
//  DateHelper.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import Foundation

class DateHelper {
    static let shared = DateHelper()
    
    func getCurrentDate(dateFormat:String, timezone:TimeZone?)->String{
        let dateGet = Date()
        let dateFormatter = DateFormatter(dateFormat: dateFormat)
        dateFormatter.timeZone = timezone
        return dateFormatter.string(from: dateGet)
    }
    
    func formatDate(dateFormat:String, date:Date, timezone:TimeZone?)->String{
        let df = DateFormatter(dateFormat: dateFormat)
        if let timezone = timezone{
            df.timeZone = timezone
        }
        df.locale = Locale.current
        
        return df.string(from: date)
    }
    
    func formatString(oldDateFormat:String, newDateFormat:String, dateString:String, timezone:TimeZone?)->String{
        let dfGet = DateFormatter(dateFormat: oldDateFormat)
        dfGet.timeZone = TimeZone(identifier: "UTC")
        let dateGet = dfGet.date(from: dateString)
        
        let dfPrint = DateFormatter(dateFormat: newDateFormat)
        dfPrint.locale = Locale.current
        if let timezone = timezone{
            dfPrint.timeZone = timezone
        }
        
        return dfPrint.string(from: dateGet!)
    }
    
    func formatISO8601(newDateFormat:String, dateString:String, timezone:TimeZone?)->String{
        let dfGet = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        dfGet.timeZone = TimeZone(identifier: "UTC")
        let dateGet = dfGet.date(from: dateString)
        
        let dfPrint = DateFormatter(dateFormat: newDateFormat)
        if let timezone = timezone{
            dfPrint.timeZone = timezone
        }
        
        return dfPrint.string(from: dateGet!)
    }
    
    func stringToDate(dateString:String, dateFormat:String, timezone:TimeZone?)->Date?{
        let df = DateFormatter(dateFormat: dateFormat)
        if let timezone = timezone{
            df.timeZone = timezone
        }
        return df.date(from: dateString)
    }
}
