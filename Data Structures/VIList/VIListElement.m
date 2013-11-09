//
//  VIListElement.m
//  21
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 viWiD. All rights reserved.
//

#import "VIListElement.h"

@implementation VIListElement

#pragma mark - List Operators

- (VIListElement *)first {
	if (_prev) return [_prev first];
	else return self;
}
- (VIListElement *)last {
	if (_next) return [_next last];
	else return self;
}

@end
