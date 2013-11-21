//
//  VIManager.h
//  21
//
//  Created by Nils Fischer on 21.11.13.
//
//

@import Foundation;
#import "VILogger.h"

@interface VIManager : NSObject

@property (strong, nonatomic, readonly) VILogger *logger;

+ (instancetype)defaultManager;

@end
