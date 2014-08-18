//
//  VIPersonTests.swift
//  VIOSFramework
//
//  Created by Nils Fischer on 17.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import XCTest

class VIPersonTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // MARK: Full Name
    
    func testFullNameWithBothNamesProvided() {
        let firstName = "Alice"
        let lastName = "Ecila"
        let person = VIPerson(firstName: firstName, lastName: lastName)
        XCTAssertNotNil(person.fullName, "Person's full name is nil, although both names were provided")
        XCTAssert(person.fullName! == firstName + " " + lastName, "Person's full name is \(person.fullName) and not \(firstName) \(lastName) (with both names provided)")
    }
    
    func testFullNameWithOnlyFirstNameProvided() {
        let firstName = "Alica"
        let person = VIPerson(firstName: firstName, lastName: nil)
        XCTAssertNotNil(person.fullName, "Person's full name is nil, although first name was provided")
        XCTAssert(person.fullName! == firstName, "Person's full name is \(person.fullName) and not \(firstName) (with only first name provided)")
    }
    
    func testFullNameWithOnlyLastNameProvided() {
        let lastName = "Ecila"
        let person = VIPerson(firstName: nil, lastName: lastName)
        XCTAssertNotNil(person.fullName, "Person's full name is nil, although last name was provided")
        XCTAssert(person.fullName! == lastName, "Person's full name is \(person.fullName) and not \(lastName) (with only last name provided)")
    }

}
