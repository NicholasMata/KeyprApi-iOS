//
//  KeyprApiTests.swift
//  KeyprApiTests
//
//  Created by Nicholas Mata on 11/27/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import XCTest
@testable import KeyprApi

let validJWT = ""
let expiredJWT = ""

let cantCheckInReservationId = ""
let failCheckInReservationId = ""
let validReservationId = failCheckInReservationId
let failCheckOutReservationId = ""
let timeoutCheckInReservationId = ""
let timeoutCheckOutReservationId = ""

let usedReservationIds = [cantCheckInReservationId, validReservationId, failCheckInReservationId,
                          failCheckOutReservationId, timeoutCheckInReservationId, timeoutCheckOutReservationId]
class KeyprApiTests: XCTestCase {
    
    var keyprApi: KeyprApi!
    
    let validJWTGenerator: KeyprJWTGenerator = { onComplete in
        onComplete(validJWT)
    }
    
    let expiredJWTGenerator: KeyprJWTGenerator = { (onComplete) in
        onComplete(expiredJWT)
    }
    
    override func setUp() {
        keyprApi = KeyprApi(jwtGenerator: validJWTGenerator,environment: .staging)
    }
    
    func getReservation(id: String) -> Reservation {
        var reservation: Reservation?
        let expectingReservation = expectation(description: "Waiting for Reservation")
        keyprApi.reservation(id: id) { (r, error) in
            reservation = r
            expectingReservation.fulfill()
        }
        wait(for: [expectingReservation], timeout: 10)
        assert(reservation != nil, "Should only use this func for valid reservations")
        return reservation!
    }
    
    func testAuthorization() {
        keyprApi.jwtGenerator = validJWTGenerator
        var error: Error?
        let expectingJWT = expectation(description: "Waiting for JWT")
        let expectingAccessToken = expectation(description: "Waiting for Access Token")
        keyprApi.checkAuthorization(jwtComplete: { (jwt, err) in
            error = err
            expectingJWT.fulfill()
        }) { (accessToken, err) in
            error = err
            expectingAccessToken.fulfill()
        }
        wait(for: [expectingJWT], timeout: 10)
        XCTAssert(error == nil, error.debugDescription)
        XCTAssert(keyprApi.jwt.isValid(), "Invalid JWT")
        wait(for: [expectingAccessToken], timeout: 10)
        XCTAssert(keyprApi.accessToken.isValid(), "Invalid access token")
    }
    
    func testExpiredJWT() {
        keyprApi.jwtGenerator = expiredJWTGenerator
        var error: Error?
        let expectingJWT = expectation(description: "Waiting for JWT")
        keyprApi.checkAuthorization(jwtComplete: { (jwt, err) in
            error = err
            expectingJWT.fulfill()
        }, accessTokenCompletion: {_,_ in  })
        wait(for: [expectingJWT], timeout: 10)
        XCTAssert(error != nil, error.debugDescription)
        XCTAssertFalse(!keyprApi.jwt.isExpired(), "JWT should be expired")
    }
    
    func testReservationDateParsing() {
        keyprApi.jwtGenerator = validJWTGenerator
        let reservation = getReservation(id: validReservationId)
        XCTAssert(reservation.attributes.createdAt != nil , "Unable to parse createdAt date")
        XCTAssert(reservation.attributes.modifiedAt != nil , "Unable to parse modifiedAt date")
        XCTAssert(reservation.attributes.checkInDate != nil , "Unable to parse checkInDate date")
        XCTAssert(reservation.attributes.checkOutDate != nil , "Unable to parse checkOutDate date")
        XCTAssert(reservation.attributes.externalModifiedDate != nil , "Unable to parse externalModifiedDate date")
    }
    
    func testFailedCheckedIn() {
        keyprApi.jwtGenerator = validJWTGenerator
        let reservation = getReservation(id: cantCheckInReservationId)
        var checkInError: Error?
        let expectingCheckIn = expectation(description: "Waiting for Check In")
        keyprApi.start(task: .checkIn, reservationId: reservation.id) { (checkInTask, err) in
            checkInError = err
            expectingCheckIn.fulfill()
        }
        wait(for: [expectingCheckIn], timeout: 3600)
        XCTAssert(checkInError?.localizedDescription == "Check-in conditions not met", "Should already be checked in.")
    }
    
    func testCheckIn() {
        keyprApi.jwtGenerator = validJWTGenerator
        var reservations: [Reservation]?
        let expectingReservation = expectation(description: "Waiting for Reservations")
        keyprApi.reservations { (pagedReservations, error) in
            reservations = pagedReservations?.data
            expectingReservation.fulfill()
        }
        wait(for: [expectingReservation], timeout: 10)
        let reservation = reservations?.first(where: { (r) -> Bool in
            return  r.attributes.state == "reserved" && !usedReservationIds.contains(r.id)})
        assert(reservation != nil, "Add a reservation using mockpms")
        var result = false
        let expectingCheckIn = expectation(description: "Waiting for Check In")
        keyprApi.perform(task:.checkIn, reservationId: reservation!.id, timeout: 10) { (successful, task, error) in
            result = successful
            expectingCheckIn.fulfill()
        }
        wait(for: [expectingCheckIn], timeout: 10)
        XCTAssert(result, "Check-in should work.")
    }
    
}
