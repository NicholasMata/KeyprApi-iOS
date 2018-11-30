//
//  WebTokenTests.swift
//  KeyprApiTests
//
//  Created by Nicholas Mata on 11/28/18.
//  Copyright © 2018 Nicholas Mata. All rights reserved.
//

import XCTest
import KeyprApi

class WebTokenTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testValidation() {
        let invalidToken = WebToken()
        XCTAssertFalse(invalidToken.isValid(), "Token should be Invalid")
        let validToken = WebToken()
        validToken.value = "QVZBTElEVE9LRU4="
        validToken.expiration = Date().addingTimeInterval(60)
        XCTAssert(validToken.isValid(), "Token should be Valid")
    }
    
    func testExpiresIn() {
        let token = WebToken()
        token.expires(in: 5)
        sleep(1)
        XCTAssert(!token.isExpired(), "Should not be expired yet")
        sleep(5)
        XCTAssert(token.isExpired(), "Should have expired")
        token.expires(in: nil)
        XCTAssert(token.isExpired(), "Expires now")
    }
    
    func testExpiredOn() {
        let token = WebToken()
        // epoch 1943470337 = August 2, 2031 8:52:17 PM
        token.expires(on: 1943470337)
        let formatter = DateFormatter()
        formatter.dateFormat = ("MM/dd/yyyy HH:mm:ssZ")
        let date = formatter.date(from: "08/02/2031 20:52:17+00:00")
        XCTAssert(token.expiration == date, "Expiration should match August 2, 2031 8:52:17 PM")
        token.expires(on: nil)
        XCTAssert(token.expiration == Date(timeIntervalSince1970: 0), "Expiration should be the start of UTC.")
    }
    
}
