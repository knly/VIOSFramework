//
//  VILogger.h
//  21
//
//  Created by Nils Fischer on 08.11.13.
//
//

@import UIKit;

enum VILogLevel {
    VILogLevelUnspecified,
    VILogLevelVerbose,
    VILogLevelDebug,
    VILogLevelInfo,
    VILogLevelWarning,
    VILogLevelError,
    VILogLevelNone
};

@interface VILogger : NSObject

@property (nonatomic) uint logLevel;

@property (weak, nonatomic) VILogger *parentLogger;

+ (VILogger *)defaultLogger;

- (void)log:(NSString *)string forLevel:(uint)logLevel;
- (void)log:(NSString *)string object:(NSObject *)object forLevel:(uint)logLevel;


@end
