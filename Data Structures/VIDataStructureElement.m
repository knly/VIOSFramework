//
//  VIDataStructureElement.m
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import "VIDataStructureElement.h"

@implementation VIDataStructureElement

+ (id)elementWithObject:(id)object {
    VIDataStructureElement *element = [[[self class] alloc] init];
    element.object = object;
    return element;
}

@end
