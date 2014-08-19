//
//  LVNGAddressBook.m
//  living
//
//  Created by Nils Fischer on 26.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

#import "VIAddressBook.h"
#import "VILogger.h"

const NSString *VIAddressBookDispatchQueueIdentifier = @"VIAddressBookDispatchQueueIdentifier";


@interface VIAddressBook () {
    
    ABAddressBookRef _addressBookRef;
    dispatch_queue_t _addressBookQueue;

}


- (dispatch_queue_t)addressBookQueue;

@end


BOOL vi_dispatch_is_current_queue_for_addressbook(VIAddressBook *addressBook)
{
    void *context = dispatch_get_specific(&VIAddressBookDispatchQueueIdentifier);
    return context == (__bridge void *)(addressBook);
}

void vi_dispatch_sync_for_addressbook(VIAddressBook *addressBook, dispatch_block_t block)
{
    if (vi_dispatch_is_current_queue_for_addressbook(addressBook)) {
        block();
    } else {
        dispatch_sync(addressBook.addressBookQueue, block);
    }
}


@implementation VIAddressBook

- (id)init
{
    if ((self = [super init])) {
        
        [self.logger log:@"Creating address book reference ..." forLevel:VILogLevelVerbose];
        
        // Create address book queue
        _addressBookQueue = dispatch_queue_create(NULL, NULL); // TODO: set label
        dispatch_queue_set_specific(_addressBookQueue, &VIAddressBookDispatchQueueIdentifier, (__bridge void *)(self), NULL);
        
        // Create address book reference
        __block ABAddressBookRef addressBook;
        __block CFErrorRef error = NULL;
        vi_dispatch_sync_for_addressbook(self, ^{
            addressBook = ABAddressBookCreateWithOptions(nil, &error);
        });
        if (error) {
            [self.logger log:@"Creating address book reference failed" error:CFBridgingRelease(error)];
            if (addressBook) CFRelease(addressBook);
            return nil;
        }
        
        // Register external change callback
        ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookExternalChangeCallback, (__bridge void *)(self));
        _addressBookRef = addressBook;
    }
    return self;
}

- (dispatch_queue_t)addressBookQueue
{
    return _addressBookQueue;
}

#pragma mark - Authorization

+ (VIAddressBookAuthorizationStatus)authorizationStatus
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusDenied: return VIAddressBookAuthorizationStatusDenied;
        case kABAuthorizationStatusRestricted: return VIAddressBookAuthorizationStatusRestricted;
        case kABAuthorizationStatusNotDetermined: return VIAddressBookAuthorizationStatusNotDetermined;
        case kABAuthorizationStatusAuthorized: return VIAddressBookAuthorizationStatusAuthorized;
    }
}

- (void)requestAuthorizationWithCompletion:(void (^)(bool granted, NSError* error))completion
{
    completion = (__bridge id)Block_copy((__bridge void *)completion);

    [self.logger log:@"Requesting address book access ..." forLevel:VILogLevelInfo];

    ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) [self.logger log:@"Address book access granted" forLevel:VILogLevelInfo];
        else [self.logger log:@"Address book access denied" error:(__bridge NSError *)(error)];
        completion(granted, (__bridge NSError*)error);
        if (error) CFRelease(error);
        Block_release((__bridge void *)completion);
    });
}


- (NSArray *)contacts
{
    if (!_contacts) {
        
        [self.logger log:@"Loading contacts ..." forLevel:VILogLevelVerbose];
        
        if (!_addressBookRef) return nil;
        
        NSMutableArray *contacts = [[NSMutableArray alloc] init];

        vi_dispatch_sync_for_addressbook(self, ^{

            NSArray *records = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(_addressBookRef));
            NSMutableSet *mergedRecords = [[NSMutableSet alloc] init];
            
            for (int i=0; i<records.count; i++) {
                ABRecordRef record = (__bridge ABRecordRef)records[i];
                if ([mergedRecords containsObject:(__bridge id)(record)]) continue;
                
                VIAddressBookContact *contact = [self newContact];
                contact.addressBook = self;
                [contact mergeInfoFromRecord:record];
                
                // merge linked records
                NSArray *linkedRecords = CFBridgingRelease(ABPersonCopyArrayOfAllLinkedPeople(record));
                if (linkedRecords.count > 1) {
                    // merge linked contact info
                    for (int j=0; j<linkedRecords.count; j++) {
                        ABRecordRef linkedRecord = (__bridge ABRecordRef)linkedRecords[j];
                        if (linkedRecord == record) continue;
                        [contact mergeInfoFromRecord:linkedRecord];
                    }
                    [mergedRecords addObjectsFromArray:linkedRecords];
                }

                [contacts addObject:contact];
            }
        });
        
        self.contacts = contacts;

    }
    return _contacts;
}

- (VIAddressBookContact *)newContact
{
    return [[VIAddressBookContact alloc] init];
}

void addressBookExternalChangeCallback(ABAddressBookRef reference, CFDictionaryRef info, void *context)
{
    [(__bridge VIAddressBook *)context addressBookDidChangeExternally];
}

- (void)addressBookDidChangeExternally
{
    [self.logger log:@"Address book did change externally" forLevel:VILogLevelInfo];
    vi_dispatch_sync_for_addressbook(self, ^{
        ABAddressBookRevert(_addressBookRef);
    });
    // TODO: update instead of reset!
    self.contacts = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:VIAddressBookDidChangeExternallyNotification object:self];
}

- (void)dealloc
{
    // TODO: release queue?
    
    if (_addressBookRef) {
        ABAddressBookUnregisterExternalChangeCallback(_addressBookRef, addressBookExternalChangeCallback, (__bridge void *)(self));
        CFRelease(_addressBookRef);
    }
}

@end
