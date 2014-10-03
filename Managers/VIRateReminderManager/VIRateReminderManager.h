//
//  VIRateReminderManager.h
//  21
//
//  Created by Nils Fischer on 02.10.14.
//
//

#import "VIManager.h"

#define kVIUserDefaultsKeyRateReminderShown @"vi_rateReminderShown"
#define kVIUserDefaultsKeyRateReminderSignificantEventCount @"vi_rateReminderSignificantEventCount"

@interface VIRateReminderManager : VIManager

@property (strong, nonatomic) NSString *appId;
@property (nonatomic) int significantEvents;
@property (nonatomic) BOOL debugMode;

@property (nonatomic, readonly) NSURL *rateURL;

- (void)tryPresentRateReminderInViewController:(UIViewController *)viewController;

- (void)significantEventDidOccur;

@end
