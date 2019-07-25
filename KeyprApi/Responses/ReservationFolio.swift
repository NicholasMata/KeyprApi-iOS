//
//  Folio.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 1/15/19.
//  Copyright © 2019 Nicholas Mata. All rights reserved.
//

import Foundation
public class ReservationFolio: Codable {
    public var bills: [Bill]
    
    public class Bill: Codable {
        public var billItems: [Item]
        public var currentBalance: AmountInfo
        
        public class Item: Codable {
            public var amount: AmountInfo
            public var date: Date
            public var description: String?
            public var transactionCode: String?
            public var originalRoom: String?
        }
        
        public class AmountInfo: Codable {
            public var amount: Float
            public var currencyCode: String
        }
    }
}
