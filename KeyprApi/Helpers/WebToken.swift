//
//  WebToken.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/28/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

/// Errors that can occur for a JSON Web Token (JWT)
public enum JWTError: LocalizedError {
    /// Payload is not base64 encoded
    case invalidPayload
    // JWT is does not contain header.payload.signature
    case invalidStructure
    /// Payload does not contain valid json
    case invalidJSON
    /// JWT payload missing key exp
    case noExpiration
    /// JWT is expired
    case expired
    
    /// A description of the error.
    public var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return "Payload does not contain valid json"
        case .invalidPayload:
            return "Payload is not base64 encoded"
        case .invalidStructure:
            return "JWT is does not contain header.payload.signature"
        case .noExpiration:
            return "JWT payload missing key exp"
        case .expired:
            return "JWT is expired"
        }
    }
    
    /// A description of how to recover from error.
    public var recoverySuggestion: String? {
        switch self {
        case .invalidJSON:
            return "Must sure payload has invalid json"
        case .invalidPayload:
            return "Base64 encode payload"
        case .invalidStructure:
            return "Go to http://jwt.io / make sure jwt is formated header.base64payload.signature"
        case .noExpiration:
            return "Add exp key to payload with token expiration in epoch time format"
        case .expired:
            return "Get a new JWT that is not expired"
        }
    }
    
}

/// A web token that has a string representation, and can expire.
public class WebToken {
    /// The token value.
    public var value: String?
    /// The expiration date of the token in UTC.
    public var expiration: Date = Date(timeIntervalSince1970: 0)
    
    public init(){}
    
    /**
     Set expiration based on epoch/unix time.
     
     - Parameter expiration: When the token should expire in epoch/unix time.
     */
    public func expires(on expiration: Double?) {
        self.expiration = Date(timeIntervalSince1970: expiration ?? 0)
    }
    /**
     Set expiration based off seconds from current time.
     
     - Parameter expiresIn: In how many seconds should the token expire.
     */
    public func expires(in expiresIn: Double?) {
        self.expiration = Date().addingTimeInterval(expiresIn ?? 0)
    }
    
    /**
     Whether the token is expired.
     - Returns: A boolean indicating whether the token is expired
     */
    public func isExpired() -> Bool {
        return expiration <= Date()
    }
    
    /**
     Whether the token is valid. meaning is not expired and has a value.
     - Returns: A boolean indicating whether the token is valid.
     */
    public func isValid() -> Bool {
        return value != nil && !isExpired()
    }
    
    /**
     Use JWT to set both expiration and token value.
     - Note: This does not check if token is already expired.
     - Parameter jwt: The json web token string value.
    */
    public func fill(jwt: String) throws {
        let jwtComponents = jwt.components(separatedBy: ".")
        guard jwtComponents.count == 3 else {
            throw JWTError.invalidStructure
        }
        let encodedPayload = jwtComponents[1]
        // According to JWT spec https://www.rfc-editor.org/rfc/rfc7515.txt base64 strings are not padded with == and swift requires padding so add padding
        let encodedPaddedPayload = encodedPayload.addBas64Padding()
        guard let decodedData = Data(base64Encoded: encodedPaddedPayload, options: .ignoreUnknownCharacters) else {
            throw JWTError.invalidPayload
        }
        do {
            guard let payload = try JSONSerialization.jsonObject(with: decodedData) as? [String: Any] else  {
                throw JWTError.invalidJSON
            }
            let expirationKey = "exp"
            guard let expiration = payload[expirationKey] as? Double else {
                throw JWTError.noExpiration
            }
            self.expires(on: expiration)
        } 
        self.value = jwt
    }
}
