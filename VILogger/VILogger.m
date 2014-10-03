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
        defaultLogger.logLevel = VILogLevelUnspecified;
    });
    return defaultLogger;

}

static NSMutableDictionary *classLoggers;

+ (VILogger *)loggerForClass:(Class)class {
    @synchronized(self) {
        NSString *classKey = NSStringFromClass(class);
        
        if (![classLoggers objectForKey:classKey]) {
            VILogger *classLogger = [[self alloc] init];
            classLogger.key = classKey;
            if (!classLoggers) classLoggers = [[NSMutableDictionary alloc] init];
            [classLoggers setObject:classLogger forKey:classKey];
        }
        return [classLoggers objectForKey:classKey];
    }
}

- (id)init {
    if ((self = [super init])) {

        self.logLevel = VILogLevelUnspecified;

    }
    return self;
}

#pragma mark - Logging

- (void)log:(NSString *)string forLevel:(VILogLevel)logLevel {
    if (logLevel != VILogLevelUnspecified) {
        if (logLevel < self.logLevel) return;
        if (logLevel == VILogLevelNone) return;
    }
    NSString *levelString = @"";
    switch (logLevel) {
        case VILogLevelUnspecified:
            levelString = @"UNSPECIFIED";
            break;
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
    NSString *keyString = self.key;
    if (keyString&&![keyString isEqualToString:@""]) {
        keyString = [keyString stringByAppendingString:@":"];
    } else {
        keyString = @"";
    }
    NSLog(@"%@%@: %@", keyString, levelString, string);
}

- (void)log:(NSString *)string object:(NSObject *)object forLevel:(VILogLevel)logLevel {
    [self log:[NSString stringWithFormat:@"%@ OBJECT: %@", string, [object description]] forLevel:logLevel];
}
    
- (void)log:(NSString *)string error:(NSError *)error {
    [self log:[NSString stringWithFormat:@"%@ ERROR: %@, %@", string, [error description], [error userInfo]] forLevel:VILogLevelError];
}

#pragma mark - Log Level

- (VILogLevel)logLevel {
    if (_logLevel==VILogLevelUnspecified&&self!=[VILogger defaultLogger]) {
        if (self.parentLogger) {
            return self.parentLogger.logLevel;
        } else {
            return [VILogger defaultLogger].logLevel;
        }
    }
    return _logLevel;
}

@end
