//
//  VIAddressBook.swift
//  living
//
//  Created by Nils Fischer on 13.06.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation
import UIKit
import AddressBook

public let VIAddressBookDidChangeExternallyNotification = "VIAddressBookDidChangeExternallyNotification"
public let VIChangedAddressBookContacts = "VIChangedAddressBookContacts"

public class VIAddressBook<C: VIAddressBookContact> {
    
    private var addressBookRef: ABAddressBookRef = {
        let addressBookRef: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()

        // TODO: register external change callback, http://stackoverflow.com/questions/25346563/address-book-external-change-callback-in-swift-with-c-function-pointers

        return addressBookRef
    }()

    
    public var contacts: [C]? {
        if VIAddressBook.authorizationStatus() != .Authorized {
            return nil
        }
        if _contacts == nil {
            _contacts = loadContacts()
        }
        return _contacts
    }
    private var _contacts: [C]?
    
    
    // MARK: Initializers

    public init() {
        
    }
    
    
    // MARK: Authorization
    
    public class func authorizationStatus() -> ABAuthorizationStatus
    {
        return ABAddressBookGetAuthorizationStatus()
    }
    public func authorizationStatus() -> ABAuthorizationStatus
    {
        return VIAddressBook.authorizationStatus()
    }
    
    public func requestAuthorization(completion: ABAddressBookRequestAccessCompletionHandler)
    {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, completion)
    }
    
    
    // MARK: Contacts Loading
    
    private func loadContacts() -> [C]
    {
        var records: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue()
        var contacts = [C]()
        var mergedRecords = [ABRecordRef]()
        for record: ABRecordRef in records {
            // TODO: don't use NSArray
            if (mergedRecords as NSArray).containsObject(record) {
                continue
            }
            
            let contact = C()
            
            let linkedRecords: NSArray = ABPersonCopyArrayOfAllLinkedPeople(record).takeRetainedValue()
            // merge all contact info
            for linkedRecord: ABRecordRef in linkedRecords {
                contact.mergeInfoFromRecord(linkedRecord)
            }
            mergedRecords.extend(linkedRecords)
            
            // TODO: use +=
            contacts.append(contact)
        }
        return contacts
    }
    
}


public class VIAddressBookContact: VIPerson {
    
    private var mergedAddressBookRecordRefs = [ABRecordRef]()
    
    public var addressBookRecordRef: ABRecordRef? {
        return mergedAddressBookRecordRefs.first
    }
    
    // TODO: necessary? the address book needs this initializer..
    public required init() {
        super.init()
    }
    
    private func mergeInfoFromRecord(record: ABRecordRef)
    {
        // TODO: lazy load data from recordRef
        if firstName == nil {
            firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty).takeRetainedValue() as? String
        }
        if lastName == nil {
            lastName = ABRecordCopyValue(record, kABPersonLastNameProperty).takeRetainedValue() as? String
        }
        if birthday == nil {
            let birthday = ABRecordCopyValue(record, kABPersonBirthdayProperty).takeRetainedValue() as? NSDate
            if birthday != nil && NSCalendar(calendarIdentifier: NSGregorianCalendar).component(.YearCalendarUnit, fromDate: birthday) != 1604 {
                self.birthday = birthday
            }
        }
        if picture == nil {
            // TODO: copying correctly?
            thumbPicture = UIImage(data: ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail).takeRetainedValue())
            picture = UIImage(data: ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatOriginalSize).takeRetainedValue())
        }
        // TODO: use +=
        mergedAddressBookRecordRefs.append(record)
    }

}
