//
//  VIAddressBookContact.h
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

@import UIKit;
@import Foundation;
@import AddressBook;
@class VIAddressBook;

@interface VIAddressBookContact : NSObject

@property (weak, nonatomic) VIAddressBook *addressBook;

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSDate *birthday;
@property (strong, nonatomic) UIImage *thumbPicture;
@property (strong, nonatomic) UIImage *picture;
@property (readonly) NSString *fullName;
@property (readonly) NSString *lastNameInitial;
@property (readonly) ABRecordRef addressBookRecordRef;

- (void)mergeInfoFromRecord:(ABRecordRef)record;

- (NSComparisonResult)leadingLastNameCompare:(VIAddressBookContact *)otherContact;

- (NSAttributedString *)attributedFullNameOfSize:(CGFloat)fontSize;

@end
