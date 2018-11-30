//
//  KeyprTask.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/29/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

public class ReservationTask: Codable {
    var id: String
    var type: String
    var attributes: TaskAttributes
    
    public class TaskAttributes: Codable {
        var name: String?
        var status: String
        var result: String?
        var ready: Bool
        var successful: Bool
        var failed: Bool
        var statusUrl: String?
    }
    
}
