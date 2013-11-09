//
//  VILogger.m
//  21
//
//  Created by Nils Fischer on 08.11.13.
//
//

#import "VILogger.h"

@implementation VILogger

+ (VILogger *)defaultLogger {

    static VILogger *defaultLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLogger = [[self alloc] init];
    });
    return defaultLogger;

}

- (id)init {
    if ((self = [super init])) {

        self.logLevel = VILogLevelDebug;

    }
    return self;
}

- (void)log:(NSString *)string forLevel:(uint)logLevel {
    if (logLevel<self.logLevel) return;
    NSString *levelString = @"";
    switch (logLevel) {
        case VILogLevelVerbose:
            levelString = @"VERBOSE";
            break;
        case VILogLevelDebug:
            levelString = @"DEBUG";
            break;
        case VILogLevelInfo:
            levelString = @"INFO";
            break;
        case VILogLevelWarning:
            levelString = @"WARNING";
            break;
        case VILogLevelError:
            levelString = @"ERROR";
            break;
        default:
            break;
    }
    NSLog(@"%@: %@", levelString, string);
}

@end
