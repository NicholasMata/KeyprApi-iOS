//
//  DateFormats.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 9/17/19.
//  Copyright © 2019 Nicholas Mata. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let reservationFolio: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter
    }()
    
    static let reservation: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}
