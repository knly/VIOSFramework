//
//  VIManagedList.m
//  card
//
//  Created by Nils Fischer on 15.12.13.
//  Copyright (c) 2013 Nils Fischer. All rights reserved.
//

#import "VIManagedList.h"

@implementation VIManagedList

- (void)setOrderedSet:(NSMutableOrderedSet *)orderedSet {
    _orderedSet = orderedSet;
    self.firstElement = [_orderedSet firstObject];
}

- (void)didAddElement:(id<VIListElement>)element {
    [self.orderedSet insertObject:element atIndex:[self indexOfElement:element]];
    [self.delegate list:self didAddElement:element];
}

- (void)didRemoveElement:(id<VIListElement>)element {
    [self.orderedSet removeObject:element];
    [self.delegate list:self didRemoveElement:element];
}

- (void)didRemoveAllElements {
    [self.orderedSet removeAllObjects];
    [self.delegate listDidRemoveAllElements:self];
}

- (BOOL)isClosed {
    return YES;
}
- (void)setClosed:(BOOL)closed {
    return;
}

@end
