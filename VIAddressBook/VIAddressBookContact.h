//
//  VIAddressBookContact.h
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

@import Foundation;
@import AddressBook;

@interface VIAddressBookContact : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSDate *birthday;
@property (strong, nonatomic) UIImage *thumbPicture;
@property (strong, nonatomic) UIImage *picture;

- (void)mergeInfoFromRecord:(ABRecordRef)record;

- (ABRecordRef)addressBookRecordRef;

- (NSString *)fullName;
- (NSString *)lastNameInitial;

@end
