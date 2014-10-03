//
//  VIUserDefaults.m
//  21
//
//  Created by Nils Fischer on 21.11.13.
//
//

#import "VIUserDefaultsSyncManager.h"

@implementation VIUserDefaultsSyncManager


#pragma mark - Object Lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Enabling Sync

- (void)setSyncEnabled:(BOOL)syncEnabled {
    if (_syncEnabled!=syncEnabled) {
        
        if (syncEnabled && (NSClassFromString(@"NSUbiquitousKeyValueStore")==nil || [NSUbiquitousKeyValueStore defaultStore]==nil)) {
            [self.logger log:@"Can't enable user defaults sync because there is no cloud key value store." forLevel:VILogLevelWarning];
            return;
        }
        
        _syncEnabled = syncEnabled;

        if (_syncEnabled) {

            // Register for NSUserDefaults changes
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localStoreDidChange:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];

            // Register for iCloud Key-Value Store changes
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:[NSUbiquitousKeyValueStore defaultStore]];

            [self.logger log:@"Enabled User Defaults Cloud Sync." forLevel:VILogLevelInfo];

            [[NSUbiquitousKeyValueStore defaultStore] synchronize];

        } else {

            [[NSNotificationCenter defaultCenter] removeObserver:self];

            [self.logger log:@"Disabled User Defaults Cloud Sync." forLevel:VILogLevelInfo];

        }
    }
}


#pragma mark - Sync Callbacks

- (void)localStoreDidChange:(NSNotification *)notification {

    // update cloud store
    NSDictionary *store = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] dictionaryWithValuesForKeys:self.userDefaultsKeys];
    [store enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj&&obj!=[NSNull null]) {
            [[NSUbiquitousKeyValueStore defaultStore] setObject:obj forKey:key];
        }
    }];
    [self.logger log:@"Pushed local User Defaults to Cloud." forLevel:VILogLevelInfo];
    [self.logger log:@"Pushed data:" object:store forLevel:VILogLevelVerbose];
}

- (void)cloudStoreDidChange:(NSNotification *)notification {

    // prevent NSUserDefaultsDidChangeNotification from being posted
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];

    // update local store
    NSDictionary *store = [[[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation] dictionaryWithValuesForKeys:self.userDefaultsKeys];
    [store enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj&&obj!=[NSNull null]) {
            [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
        }
    }];
    [self.logger log:@"Updated local User Defaults from Cloud." object:store forLevel:VILogLevelInfo];
    [self.logger log:@"Updated data:" object:store forLevel:VILogLevelVerbose];

    //[[NSUserDefaults standardUserDefaults] synchronize];

    // re-enable NSUserDefaultsDidChangeNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localStoreDidChange:) name:NSUserDefaultsDidChangeNotification object:[NSUserDefaults standardUserDefaults]];
}

@end
