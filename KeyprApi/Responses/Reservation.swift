//
//  Reservation.swift
//  KeyprApi
//
//  Created by Nicholas Mata on 11/29/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import Foundation

/// A reservation for a guest.
public class Reservation: Codable {
    /// The reservations identifier
    public var id: String
    /// The type of reservation. Currently only one type *reservation*.
    public var type: String
    /// Attributes about the reservation.
    public var attributes: Attributes
    /// Relationships the reservation has.
    public var relationships: Relationships
    /// Metadata regarding this reservation, that can be helpful implementing user flows in an API client.
    public var meta: Metadata
    
    
    public class Relationships: Codable {
        public var users: UserRelationships
        public var affiliate: AffilateRelationship
        public var locations: LocationRelationship?
        
        public class LocationRelationship: Codable {
            public var data: [Relationship]
        }
        public class UserRelationships: Codable {
            public var data: [Relationship]
        }
        
        public class AffilateRelationship: Codable {
            public var data: Relationship
        }
        
        public class Relationship:Codable {
            public var id:String
            public var type:String
        }
    }
    
    /// Metadata regarding a reservation
    public class Metadata: Codable {
        public var folioDetailsUrl: String
        /// Indicates if remote check-in operation can be attempted. When this field is set to false, controls allowing to submit a check-in request should be hidden or disabled.
        public var canCheckIn: Bool
        /// Indicates if remote check-out operation can be attempted. When this field is set to false, controls allowing to submit a check-out request should be hidden or disabled.
        public var canCheckOut: Bool
        public var isDueIn: Bool
        public var isDueOut: Bool
        public var isAssigned: Bool
        public var canPreCheckIn: Bool
    }
    
    /// The states a reservation can be in.
    public enum State: String, Codable {
        /// Temporary state that indicates a newly created data record
        case pending
        /// Future reservation
        case reserved
        /// Guest has checked in, current time should be between checkin_date and checkout_date
        case checkedIn = "checked_in"
        /// Guest checked out today, state will be set to archived next day
        case checkedOut = "checked_out"
        /// Past reservation
        case archived
        /// Indicates that reservation was canceled or guest did not show up
        case canceled
    }
    
    /// Attributes about a reservation.
    public class Attributes: Codable {
        /// The state of the reservation
        public var state: Reservation.State
        /// ID used by external system (usually Property Management System)
        public var externalId: String
        /// Reservation confirmation number
        public var confirmationId: String?
        /// The first (given) name of the guest
        public var firstName: String?
        /// The last (family) name / surname of the guest
        public var lastName: String?
        /// The middle name of the guest
        public var middleName:String?
        /// The email address of the guest
        public var email: String
        /// The phone number of the guest
        public var phone: String?
        /// The address of the guest
        public var address:String?
        /// The postal code / zipcode of the guest
        public var postalCode:String?
        public var company:String?
        public var loyaltyProgram:String?
        public var loyaltyNumber:String?
        public var blockCode:String?
        public var externalState:String?
        /// The OAuth application responsible for checking the guest in.
        public var checkInOAuthAppId:String?
        /// The source responsible for checking the guest in. (mobile,pms) seen so far.
        public var checkInSourceType:String?
        /// The OAuth application responsible for checking the guest out.
        public var checkOutOAuthAppId:String?
        /// The source responsible for checking the guest out. (mobile,pms) seen so far.
        public var checkOutSourceType:String?
        /// Whether digital /mobile key is disabled
        public var digitalKeyDisabled: Bool?
        /// Metadata on the attributes of the reservation.
        public var metaFields: MetaFields
        
        /// The date the reservation was created
        lazy public var createdAt: Date? = {
            return _createdAt.toDate()
        }()
        /// The date the last modification of the reservation occurred.
        lazy public var modifiedAt: Date? = {
            return _modifiedAt.toDate()
        }()
        /// The date the guest checked in.
        lazy public var checkInDate: Date? = {
            return _checkInDate.toDate()
        }()
        /// The date the guest checked out.
        lazy public var checkOutDate: Date? = {
            return _checkOutDate.toDate()
        }()
        /// The date the last external modification of the reservation occurred.
        lazy public var externalModifiedDate: Date? = {
            return _externalModifiedDate?.toDate()
        }()
        
        private var _modifiedAt: String
        private var _createdAt: String
        private var _checkInDate: String
        private var _checkOutDate: String
        private var _externalModifiedDate:String?
        
        enum CodingKeys: String, CodingKey {
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
        
        /// Metadata on the attributes of a reservation to see
        /// if electronic check in/out is enabled for reservation.
        public class MetaFields: Codable {
            /// Whether electronic checkout is enabled for a reservation.
            public var eCheckOutEnabled: Bool?
            /// Whether electronic checkin is enabled for a reservation.
            public var eCheckInEnabled: Bool?
            
            enum CodingKeys: String, CodingKey {
                case eCheckOutEnabled = "echeckoutEnabled"
                case eCheckInEnabled = "echeckinEnabled"
            }
        }
    }
}
