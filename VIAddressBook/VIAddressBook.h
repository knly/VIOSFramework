//
//  VIAddressBook.h
//  VIOSFramework
//
//  Created by Nils Fischer on 26.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//
//  Reference: https://github.com/heardrwt/RHAddressBook/blob/master/RHAddressBook/RHAddressBook.m
//

@import Foundation;
@import AddressBook;
#import "VIAddressBookContact.h"

#define VIAddressBookDidChangeExternallyNotification @"VIAddressBookDidChangeExternallyNotification"

typedef enum : NSUInteger {
    VIAddressBookAuthorizationStatusDenied,
    VIAddressBookAuthorizationStatusRestricted,
    VIAddressBookAuthorizationStatusNotDetermined,
    VIAddressBookAuthorizationStatusAuthorized,
} VIAddressBookAuthorizationStatus;


@interface VIAddressBook : NSObject

@property (strong, nonatomic) NSMutableArray *contacts;

+ (VIAddressBookAuthorizationStatus)authorizationStatus;
- (void)requestAuthorizationWithCompletion:(void (^)(bool granted, NSError* error))completion;

// TODO: really expose this? ABPersonViewController doesn't trigger it..
- (void)addressBookDidChangeExternally;

- (VIAddressBookContact *)newContact;

@end
