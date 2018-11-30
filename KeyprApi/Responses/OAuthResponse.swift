//
//  FederatedTokenResponse.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/28/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

public class FederatedTokenBody: Codable {
    var jwt: String
    init(jwt:String) {
        self.jwt = jwt
    }
}

public class OAuthResponse: Codable {
    public var accessToken: String
    public var expiresIn: Double
    public var tokenType: String
    public var scope: String
    public var refreshToken: String
    public var idToken: String
}
