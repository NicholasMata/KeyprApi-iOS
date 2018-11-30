//
//  ErrorResponse.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/28/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

public class ErrorResponse: Decodable {
    public var detail: String
}

public class ErrorObjectResponse: Decodable {
    public var errors: [ErrorResponse]
}
