//
//  DateFormatter+Ext.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 05/01/21.
//

import Foundation

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
