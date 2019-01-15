//
//  PagedResponse.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/29/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

/// A paged json response from keypr server.
public class PagedResponse<T: Codable>: Codable {
    /// Information about pages
    public var pagingInfo: PagingInfo
    /// The data that this page holds normally a list of some json object.
    public var data: T
    public var included: [AdditionalInfo]?
    
    enum CodingKeys: String, CodingKey {
        case pagingInfo = "links"
        case data
        case included
    }
    
    /// Information needed to navigate pages
    public class PagingInfo: Codable {
        /// A url to the first page.
        public var first: String
        /// A url to the next page.
        public var next: String?
        /// a url to the previous page.
        public var prev: String?
    }
    
    public class AdditionalInfo : Codable {
        public var id: String
        public var type: String
        public var attributes: Attributes
        
        public class Attributes: Codable {
            public var name: String?
            public var locationStatus: String?
            public var externalId: String?
        }
    }
}
