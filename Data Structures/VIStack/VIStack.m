//
//  VIStack.m
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import "VIStack.h"

@interface VIStack ()

@property (strong, nonatomic) NSMutableArray *elements;
@property (weak, nonatomic) VIStackElement *top;

@end

@implementation VIStack

- (id)init {
    if (self=[super init]) {
        self.elements = [[NSMutableArray alloc] init];
    }
    return self;
}

- (VIStackElement *)top {
    return _top;
}

- (void)push:(VIStackElement *)element {
    if (!element) return;
    [self.elements addObject:element];
    element.prev = self.top;
    self.top = element;
}

- (VIStackElement *)pop {
    if (!self.top) return nil;
    VIStackElement *top = self.top;
    self.top = self.top.prev;
    [self.elements removeObject:top];
    return top;
}

- (BOOL)isEmpty {
    return self.top==nil;
}

- (void)clear {
    while (!self.isEmpty) {
        [self pop];
    }
}

@end
