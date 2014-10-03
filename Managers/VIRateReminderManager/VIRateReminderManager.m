//
//  VIRateReminderManager.m
//  21
//
//  Created by Nils Fischer on 02.10.14.
//
//

#import "VIRateReminderManager.h"
#import "VILogger.h"


@interface VIRateReminderManager ()

@end


@implementation VIRateReminderManager

- (void)tryPresentRateReminderInViewController:(UIViewController *)viewController {
    if (![self shouldPresentRateReminder]) {
        [self.logger log:@"Tried presenting rate reminder but failed." forLevel:VILogLevelInfo];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"vi_rate_reminder_title", nil) message:NSLocalizedString(@"vi_rate_reminder_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"vi_rate_reminder_decline_button_title", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.logger log:@"User declined rate reminder." forLevel:VILogLevelInfo];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVIUserDefaultsKeyRateReminderShown];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"vi_rate_reminder_later_button_title", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.logger log:@"User dismissed rate reminder to be reminded later." forLevel:VILogLevelInfo];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"vi_rate_reminder_rate_button_title", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.logger log:@"User accepted rate reminder." forLevel:VILogLevelInfo];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVIUserDefaultsKeyRateReminderShown];
        [[UIApplication sharedApplication] openURL:self.rateURL];
    }]];
    [viewController presentViewController:alertController animated:YES completion:nil];
    [self.logger log:@"Presented rate reminder." forLevel:VILogLevelInfo];
}

- (NSURL *)rateURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", self.appId]];
}

- (BOOL)shouldPresentRateReminder {
    if (self.debugMode) {
        [self.logger log:@"Showing rate reminder in debug mode - remember to turn this of for production." forLevel:VILogLevelWarning];
        return YES;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kVIUserDefaultsKeyRateReminderShown]) {
        [self.logger log:@"Rate reminder was already shown before." forLevel:VILogLevelDebug];
        return NO;
    }
    if ([[NSUserDefaults standardUserDefaults] integerForKey:kVIUserDefaultsKeyRateReminderSignificantEventCount] < self.significantEvents) {
        [self.logger log:[NSString stringWithFormat:@"Only %d significant events have occured yet with a threshold of %d", [[NSUserDefaults standardUserDefaults] integerForKey:kVIUserDefaultsKeyRateReminderSignificantEventCount], self.significantEvents] forLevel:VILogLevelDebug];
        return NO;
    }
    return YES;
}

- (void)significantEventDidOccur
{
    int significantEventsCount = [[NSUserDefaults standardUserDefaults] integerForKey:kVIUserDefaultsKeyRateReminderSignificantEventCount] + 1;
    [self.logger log:[NSString stringWithFormat:@"Significant event occured with a total of %d.", significantEventsCount] forLevel:VILogLevelDebug];
    [[NSUserDefaults standardUserDefaults] setInteger:significantEventsCount forKey:kVIUserDefaultsKeyRateReminderSignificantEventCount];
}

@end
