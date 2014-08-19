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
    if (!self.birthday) {
        NSDate *birthday = CFBridgingRelease(ABRecordCopyValue(record, kABPersonBirthdayProperty));
        if (birthday && [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] component:NSCalendarUnitYear fromDate:birthday] != 1604) {
            self.birthday = birthday;
        }
    }
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

- (NSComparisonResult)leadingLastNameCompare:(VIAddressBookContact *)otherContact
{
    VIAddressBookContact *obj1 = self;
    VIAddressBookContact *obj2 = otherContact;
    if (!obj1.fullName && obj2.fullName) return NSOrderedDescending;
    if (obj1.fullName && !obj2.fullName) return NSOrderedAscending;
    if (!obj1.fullName && !obj2.fullName) return NSOrderedSame;
    NSString *str1 = (obj1.lastName) ? obj1.lastName : obj1.firstName;
    NSString *str2 = (obj2.lastName) ? obj2.lastName : obj2.firstName;
    return [str1 caseInsensitiveCompare:str2];
}

- (NSAttributedString *)attributedFullNameOfSize:(CGFloat)fontSize
{
    if (!self.fullName) return nil;
    NSMutableAttributedString *attributedName = [[NSMutableAttributedString alloc] initWithString:self.fullName];
    [attributedName beginEditing];
    if (self.lastName) {
        [attributedName addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:NSMakeRange(self.firstName.length > 0 ? self.firstName.length + 1 : 0, self.lastName.length)];
    } else {
        [attributedName addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:fontSize] range:NSMakeRange(0, self.firstName.length)];
    }
    [attributedName endEditing];
    return attributedName;
    
}

@end
