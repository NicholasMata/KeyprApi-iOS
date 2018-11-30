//
//  FederatedTokenResponse.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/28/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

internal class FederatedTokenBody: Codable {
    public var jwt: String
    init(jwt:String) {
        self.jwt = jwt
    }
}

/// A json response gotten from a successful OAuth request.
public class OAuthResponse: Codable {
    /// An access token.
    public var accessToken: String
    /// How many seconds from now the access token will expire.
    public var expiresIn: Double
    /// The type of token usually *Bearer*
    public var tokenType: String
    /// The value of the scope parameter is expressed as a list of space-
    /// delimited, case-sensitive strings.  The strings are defined by the
    /// authorization server.
    public var scope: String
    /// A refresh token that can be used to get another access token.
    public var refreshToken: String
    /// The id token is a JSON Web Token (JWT) that contains user profile information
    public var idToken: String
}
