//
//  VIList.m
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import "VIList.h"

@interface VIList ()

@property (weak, nonatomic) VIListElement *firstElement;

@property (strong, nonatomic) NSMutableArray *elements;

@end

@implementation VIList

- (id)init {
    if (self = [super init]) {
		
        _elements = [[NSMutableArray alloc] init];
		_closed = NO;
		
    }
    return self;
}

#pragma mark - Closed List

- (void)setClosed:(BOOL)closed {
	if (closed) {
		_firstElement.prev = self.lastElement;
        if (!_firstElement.prev) _firstElement.prev = [_firstElement last]; // hasn't been connected before
		_firstElement.prev.next = _firstElement;
	} else {
		_firstElement.prev.next = nil;
		_firstElement.prev = nil;
	}
	_closed = closed;
}

#pragma mark - List Operations

#pragma mark Adding Elements

- (void)addObject:(id)object {
	if (!object) return;
	[self appendElement:[VIListElement elementWithObject:object]];
}
- (void)appendElement:(VIListElement *)element {
    [self insertElement:element afterElement:self.lastElement];
}
- (void)insertElement:(VIListElement *)element afterElement:(VIListElement *)preElement {
    if (!element) return;
    if (!_elements) _elements = [[NSMutableArray alloc] init];
    [_elements addObject:element];
    if (preElement) {
        element.prev = preElement;
        element.next = preElement.next;
    } else {
        element.prev = _firstElement.prev;
        element.next = _firstElement;
        _firstElement = element;
    }
    element.prev.next = element;
    element.next.prev = element;
    if (!_firstElement) {
		_firstElement = element;
	}
    self.closed = _closed;
}

#pragma mark Removing Elements

- (void)removeObject:(id)object {
    [self removeElement:[self elementForObject:object]];
}
- (void)removeElement:(VIListElement *)element {
	if (element==self.firstElement) _firstElement = _firstElement.next;
	if (element==self.currentElement) _currentElement = nil;
	element.prev.next = element.next;
	element.next.prev = element.prev;
	[_elements removeObject:element];
}
- (void)removeAllElements {
	[_elements removeAllObjects];
	_firstElement = nil;
    _currentElement = nil;
}

#pragma mark Retrieving Elements

- (VIListElement *)lastElement {
	if (_closed) return _firstElement.prev;
	return [_firstElement last];
}

- (VIListElement *)elementAtOffset:(int)offset {
	VIListElement *cu = self.currentElement;
	for (int i=0; i<offset; i++) {
		cu = cu.next;
	}
	return cu;
}
- (VIListElement *)elementAtIndex:(int)index {
    if (index<0||index>=[self count]) return nil;
	VIListElement *cu = self.firstElement;
	for (int i=0; i<index; i++) {
		cu = cu.next;
	}
	return cu;
}
- (VIListElement *)elementForObject:(id)object {
    if (!object) return nil;
	VIListElement *cu = self.firstElement;
	VIListElement *start = cu;
	while (cu&&!(_closed&&cu==start)) {
		if (cu.object==object) {
            return cu;
		}
		cu = cu.next;
	}
    return nil;
}

- (BOOL)containsElement:(VIListElement *)element {
    return [_elements containsObject:element];
}

- (int)count {
    return [_elements count];
}

#pragma mark Navigating

- (void)moveToFirst {
    _currentElement = self.firstElement;
}
- (void)moveToLast {
    _currentElement = self.lastElement;
}

- (VIListElement *)stepNext {
	VIListElement *cu = _currentElement;
	_currentElement = _currentElement.next;
	return cu;
}
- (VIListElement *)stepPrev {
	_currentElement = _currentElement.prev;
	return _currentElement;
}

#pragma mark More

- (void)setCurrentElement:(VIListElement *)currentElement {
    if (![self containsElement:currentElement]) return;
    _currentElement = currentElement;
}

- (void)shuffleElements {
    if (!_firstElement) return;
    
	VIListElement *preFirst = self.firstElement;
	VIListElement *newLast = nil;
	// pick random elements and move to new list
	VIListElement *cu;
	int remaining = [_elements count];
	while (preFirst) {
		// go to random element in old list
		int rnd = arc4random()%remaining;
		remaining--;
		cu = preFirst;
		for (int i=0; i<rnd; i++) {
			cu = cu.next;
		}
		// link elements around picked one in old list
		if (cu==preFirst) preFirst = preFirst.next;
		cu.prev.next = cu.next;
		cu.next.prev = cu.prev;
		// append to new list
		newLast.next = cu;
		cu.prev = newLast;
		cu.next = nil;
		newLast = cu;
	}
    _firstElement = [newLast first];
    self.closed = _closed;
}

- (NSArray *)orderedElementsAscending:(BOOL)ascending {
    NSMutableArray *orderedElements = [[NSMutableArray alloc] init];
    VIListElement *cu = (ascending)?self.firstElement:self.lastElement;
	VIListElement *start = cu;
    [orderedElements addObject:cu];
    while ((cu = (ascending)?cu.next:cu.prev)&&!(_closed&&cu==start)) [orderedElements addObject:cu];
    return orderedElements;
}

@end
