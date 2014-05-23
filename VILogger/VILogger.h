//
//  VILogger.h
//  21
//
//  Created by Nils Fischer on 08.11.13.
//
//

@import Foundation;

typedef enum : NSUInteger {
    VILogLevelUnspecified, // Initial level, messages are always logged
    VILogLevelVerbose,
    VILogLevelDebug,
    VILogLevelInfo,
    VILogLevelWarning,
    VILogLevelError,
    VILogLevelNone // Messages are never logged
} VILogLevel;


@interface VILogger : NSObject

@property (nonatomic) VILogLevel logLevel;

@property (strong, nonatomic) NSString *key;

@property (weak, nonatomic) VILogger *parentLogger;

+ (VILogger *)defaultLogger;
+ (VILogger *)loggerForClass:(Class)class;

- (void)log:(NSString *)string forLevel:(VILogLevel)logLevel;
- (void)log:(NSString *)string object:(NSObject *)object forLevel:(VILogLevel)logLevel;
- (void)log:(NSString *)string error:(NSError *)error;


@end


@interface NSObject (VILogger)

- (VILogger *)logger;

@end

@implementation NSObject (VILogger)

- (VILogger *)logger {
    return [VILogger loggerForClass:[self class]];
}

@end
