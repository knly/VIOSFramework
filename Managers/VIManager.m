//
//  VIManager.m
//  21
//
//  Created by Nils Fischer on 21.11.13.
//
//

#import "VIManager.h"

@interface VIManager ()

@property (strong, nonatomic) VILogger *logger;

@end

@implementation VIManager

#pragma mark - Singleton

static NSMutableDictionary *defaultManagers;

+ (instancetype)defaultManager {
    id defaultManager = nil;

    @synchronized(self) {
        NSString *managerClassKey = NSStringFromClass(self);

        defaultManager = [defaultManagers objectForKey:managerClassKey];

        if (!defaultManager) {
            defaultManager = [[self alloc] init];
            if (!defaultManagers) defaultManagers = [[NSMutableDictionary alloc] init];
            [defaultManagers setObject:defaultManager forKey:managerClassKey];
        }
    }

    return defaultManager;
}

#pragma mark - Logger

- (VILogger *)logger {
    if (!_logger) {
        self.logger = [[VILogger alloc] init];
    }
    return _logger;
}

@end
