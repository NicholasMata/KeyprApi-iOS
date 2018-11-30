//
//  PagedResponse.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/29/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

public class PagingInfo: Codable {
    public var first: String
    public var next: String?
    public var prev: String?
}

public class PagedResponse<T: Codable>: Codable {
    public var pagingInfo: PagingInfo
    public var data: T
    
    public enum CodingKeys: String, CodingKey {
        case pagingInfo = "links"
        case data
    }
}
