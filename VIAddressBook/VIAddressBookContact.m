//
//  VIAddressBookContact.m
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

#import "VIAddressBookContact.h"

@interface VIAddressBookContact ()

@property (strong, nonatomic) NSMutableArray *mergedAddressBookRecordRefs;

@end

@implementation VIAddressBookContact

- (void)mergeInfoFromRecord:(ABRecordRef)record
{
    if (!self.mergedAddressBookRecordRefs) self.mergedAddressBookRecordRefs = [[NSMutableArray alloc] init];
    [self.mergedAddressBookRecordRefs addObject:(__bridge id)(record)];
    if (!self.firstName) self.firstName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
    if (!self.lastName) self.lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
    if (!self.birthday) self.birthday = CFBridgingRelease(ABRecordCopyValue(record, kABPersonBirthdayProperty));
    if (!self.picture) {
        self.thumbPicture = [UIImage imageWithData:CFBridgingRelease(ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail))];
        self.picture = [UIImage imageWithData:CFBridgingRelease(ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatOriginalSize))];
    }
}

- (ABRecordRef)addressBookRecordRef
{
    return (__bridge ABRecordRef)([self.mergedAddressBookRecordRefs firstObject]);
}

- (NSString *)fullName
{
    if (!self.firstName) return self.lastName;
    if (!self.lastName) return self.firstName;
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)lastNameInitial
{
    if (self.lastName && self.lastName.length > 0) return [[self.lastName substringToIndex:1] capitalizedString];
    if (self.firstName && self.firstName.length > 0) return [[self.firstName substringToIndex:1] capitalizedString];
    return nil;
}

@end
