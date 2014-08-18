//
//  VIPerson.swift
//  VIOSFramework
//
//  Created by Nils Fischer on 16.08.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

import Foundation
import UIKit

// TODO: remove NSObject inheritance, only necessary for KVO

public class VIPerson: NSObject {

    
    // MARK: Public Properties
    
    public var firstName: String?
    public var lastName: String?
    public var birthday: NSDate?
    public var thumbPicture: UIImage?
    public var picture: UIImage?
    
    
    // MARK: Computed Properties
    
    public var fullName: String? {
        if firstName == nil {
            return lastName
        } else if lastName == nil {
            return firstName
        } else {
            return "\(firstName!) \(lastName!)"
        }
    }
    
    public var lastNameInitial: String? {
        if lastName != nil && countElements(lastName!) > 0 {
            // TODO: use String instead of NSString
            return (lastName! as NSString).substringToIndex(1).capitalizedString
        } else if firstName != nil && countElements(firstName!) > 0 {
            return (firstName! as NSString).substringToIndex(1).capitalizedString
            }
            return nil
    }

    
    // MARK: Initializers
    
    // TODO: required only to make address book work..
    public required override init() {
        
    }
    
    public convenience init(firstName: String?, lastName: String?) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
    }

    
    // MARK: Comparisons
    
    public func leadingLastNameCompare(otherContact: VIPerson) -> NSComparisonResult
    {
        let obj1 = self
        let obj2 = otherContact
        if obj1.fullName == nil && obj2.fullName != nil {
            return .OrderedDescending
        } else if obj1.fullName != nil && obj2.fullName == nil {
            return .OrderedAscending
        } else if obj1.fullName == nil && obj2.fullName == nil {
            return .OrderedSame
        }
        let str1 = obj1.lastName ?? obj1.firstName!
        let str2 = obj2.lastName ?? obj2.firstName!
        return str2.caseInsensitiveCompare(str2)
    }
    
    
    // MARK: Interface Output
    // TODO: move somewhere else?
    
    public func attributedFullNameOfSize(fontSize: CGFloat) -> NSAttributedString?
    {
        if let fullName = self.fullName {
            var attributedName = NSMutableAttributedString(string: fullName)
            attributedName.beginEditing()
            if lastName != nil {
                var beginBoldFont = countElements(firstName!)
                if beginBoldFont > 0 {
                    beginBoldFont++
                }
                attributedName.addAttribute(NSFontAttributeName, value:UIFont.boldSystemFontOfSize(fontSize), range:NSMakeRange(beginBoldFont, countElements(lastName!)))
            } else {
                attributedName.addAttribute(NSFontAttributeName, value:UIFont.boldSystemFontOfSize(fontSize), range:NSMakeRange(0, countElements(firstName!)))
            }
            attributedName.endEditing()
            return attributedName
        } else {
            return nil
        }
    }
    
}
