//
//  VILogger.h
//  21
//
//  Created by Nils Fischer on 08.11.13.
//
//

@import Foundation;

enum VILogLevel {
    VILogLevelUnspecified, // Initial level, messages are always logged
    VILogLevelVerbose,
    VILogLevelDebug,
    VILogLevelInfo,
    VILogLevelWarning,
    VILogLevelError,
    VILogLevelNone // Messages are never logged
};

@interface VILogger : NSObject

@property (nonatomic) uint logLevel;

@property (strong, nonatomic) NSString *key;

@property (weak, nonatomic) VILogger *parentLogger;

+ (VILogger *)defaultLogger;
+ (VILogger *)loggerForClass:(Class)class;

- (void)log:(NSString *)string forLevel:(uint)logLevel;
- (void)log:(NSString *)string object:(NSObject *)object forLevel:(uint)logLevel;
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
