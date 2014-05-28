//
//  VISection.h
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

@import Foundation;
#import "VIArraySectionInfo.h"

@interface VIArraySection : NSObject <VIArraySectionInfo>

@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *indexTitle;

- (void)addObject:(id)object;

@end
