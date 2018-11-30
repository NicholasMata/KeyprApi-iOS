//
//  WebToken.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/28/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

public enum JWTError: LocalizedError {
    case invalidPayload
    case invalidStructure
    case invalidJSON
    case noExpiration
    case expired
    
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

public class WebToken {
    public var value: String?
    public var expiration: Date = Date(timeIntervalSince1970: 0)
    
    public init(){}
    
    public func expires(on expiration: Double?) {
        self.expiration = Date(timeIntervalSince1970: expiration ?? 0)
    }
    public func expires(in expiresIn: Double?) {
        self.expiration = Date().addingTimeInterval(expiresIn ?? 0)
    }
    
    public func isExpired() -> Bool {
        return expiration <= Date()
    }
    
    public func isValid() -> Bool {
        return value != nil && !isExpired()
    }
    
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
