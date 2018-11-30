//
//  Reservation.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/29/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

public class ReservationAttributes: Codable {
    var state: String
    var externalId: String
    var confirmationId: String
    var firstName: String?
    var lastName: String?
    var middleName:String?
    var email: String
    var phone: String?
    var address:String?
    var postalCode:String?
    var company:String?
    var loyaltyProgram:String?
    var loyaltyNumber:String?
    var blockCode:String?
    var externalState:String
    var checkInOAuthAppId:String?
    var checkInSourceType:String?
    var checkOutOAuthAppId:String?
    var checkOutSourceType:String?
    var digitalKeyDisabled: Bool?
    var metaFields: ReservationAttributesMetaFields
    
    lazy var createdAt: Date? = {
        return _createdAt.toDate()
    }()
    lazy var modifiedAt: Date? = {
        return _modifiedAt.toDate()
    }()
    lazy var checkInDate: Date? = {
        return _checkInDate.toDate()
    }()
    lazy var checkOutDate: Date? = {
        return _checkOutDate.toDate()
    }()
    lazy var externalModifiedDate: Date? = {
        return _externalModifiedDate.toDate()
    }()
    
    private var _modifiedAt: String
    private var _createdAt: String
    private var _checkInDate: String
    private var _checkOutDate: String
    private var _externalModifiedDate:String
    
    public enum CodingKeys: String, CodingKey {
        case state
        case externalId
        case confirmationId
        case firstName
        case lastName
        case middleName
        case email
        case phone
        case address
        case postalCode
        case company
        case loyaltyProgram
        case loyaltyNumber
        case blockCode
        case externalState
        case checkInOAuthAppId
        case checkInSourceType
        case checkOutOAuthAppId
        case checkOutSourceType
        case digitalKeyDisabled
        case metaFields
        case _createdAt = "createdAt"
        case _modifiedAt = "modifiedAt"
        case _checkInDate = "checkinDate"
        case _checkOutDate = "checkoutDate"
        case _externalModifiedDate = "externalModifiedDate"
    }
    
    public class ReservationAttributesMetaFields: Codable {
        var eCheckOutEnabled: Bool
        var eCheckInEnabled: Bool
        
        enum CodingKeys: String, CodingKey {
            case eCheckOutEnabled = "echeckoutEnabled"
            case eCheckInEnabled = "echeckinEnabled"
        }
    }
}


public class Reservation: Codable {
    var id: String
    var type: String
    var attributes: ReservationAttributes
    var relationships: ReservationRelationships
    var meta: ReservationMetadata
    
    
    public class ReservationRelationships: Codable {
        var users: ReservationUserRelationships
        var affiliate: ReservationAffilateRelationship
        
        public class ReservationUserRelationships: Codable {
            var data: [Relationship]
        }
        
        public class ReservationAffilateRelationship: Codable {
            var data: Relationship
        }
        
        public class Relationship:Codable {
            var id:String
            var type:String
        }
    }
    
    public class ReservationMetadata: Codable {
        var canCheckIn: Bool
        var isDueIn: Bool
        var canCheckOut: Bool
        var isDueOut: Bool
        var isAssigned: Bool
        var canPreCheckIn: Bool
    }
}
