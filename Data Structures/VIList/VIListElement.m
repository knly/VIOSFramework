//
//  VIListElement.m
//  21
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 viWiD. All rights reserved.
//

#import "VIListElement.h"

@implementation VIListElement

@synthesize prev = _prev, next = _next;

#pragma mark - List Operators

- (id <VIListElement>)first {
	if (self.prev) return [self.prev first];
	else return self;
}
- (id <VIListElement>)last {
	if (self.next) return [self.next last];
	else return self;
}

@end
