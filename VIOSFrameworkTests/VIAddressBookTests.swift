//
//  VIAddressBookTests.swift
//  VIOSFramework
//
//  Created by Nils Fischer on 17.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import XCTest

class VIAddressBookTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    // MARK: Authorization
    
    func testAuthorization() {
        let authorizationStatus = VIAddressBook.authorizationStatus()
        XCTAssert(authorizationStatus == .Authorized, "Address Book access is not authorized.")
    }
    
    
    // MARK: Loading Contacts
    
    class CustomAddressBookContact: VIAddressBookContact {
        var customFullName: String? {
            return fullName?.uppercaseString
        }
    }

    func testLoadingContacts() {
        let addressBook = VIAddressBook<VIAddressBookContact>()
        let contacts = addressBook.contacts
        // TODO: use XCTAssertNotNil
        XCTAssert(contacts != nil, "Unable to access contacts.")
    }
    
    func testLoadingCustomContacts() {
        let addressBook = VIAddressBook<CustomAddressBookContact>()
        let contacts = addressBook.contacts
        // TODO: use XCTAssertNotNil
        XCTAssert(contacts != nil, "Unable to access contacts with custom contact type.")
        for contact in contacts! {
            println(contact.customFullName)
        }
    }

}
