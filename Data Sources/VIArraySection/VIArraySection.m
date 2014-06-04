//
//  VISection.m
//  living
//
//  Created by Nils Fischer on 28.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

#import "VIArraySection.h"

@implementation VIArraySection

- (void)addObject:(id)object
{
    if (!self.objects) self.objects = [[NSMutableArray alloc] init];
    [self.objects addObject:object];
}

- (NSInteger)numberOfObjects
{
    return self.objects.count;
}

@end
