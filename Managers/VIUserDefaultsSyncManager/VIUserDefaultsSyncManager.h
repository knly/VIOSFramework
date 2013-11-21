//
//  VIUserDefaults.h
//  21
//
//  Created by Nils Fischer on 21.11.13.
//
//

@import Foundation;
#import "VIManager.h"

@interface VIUserDefaultsSyncManager : VIManager

@property (nonatomic, getter=isSyncEnabled) BOOL syncEnabled;
@property (strong, nonatomic) NSArray *userDefaultsKeys;

- (void)localStoreDidChange:(NSNotification *)notification;

@end
