//
//  VILogger.h
//  21
//
//  Created by Nils Fischer on 08.11.13.
//
//

@import UIKit;

enum VILogLevel {
    VILogLevelVerbose,
    VILogLevelDebug,
    VILogLevelInfo,
    VILogLevelWarning,
    VILogLevelError,
    VILogLevelNone
};

@interface VILogger : NSObject

@property (nonatomic) uint logLevel;

+ (VILogger *)defaultLogger;

- (void)log:(NSString *)string forLevel:(uint)logLevel;

@end
