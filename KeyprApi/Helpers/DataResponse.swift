//
//  DataResponse.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/30/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

internal class DataResponse<T: Codable>: Codable {
    public var data: T
}
