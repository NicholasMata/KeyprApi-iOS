//
//  ErrorResponse.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/28/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

/// A json error response that is defined by keypr server.
public class ErrorResponse: Decodable {
    /// Details about the error that occurred
    public var detail: String
}

/// A json error response that is defined by keypr server.
public class ErrorObjectResponse: Decodable {
    /// List of one or more errors that occurred.
    public var errors: [ErrorResponse]
}
