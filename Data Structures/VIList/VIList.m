//
//  VIList.m
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import "VIList.h"

@interface VIList ()

@property (strong, nonatomic) NSMutableArray *elements;

@end

@implementation VIList

- (id)init {
    if (self = [super init]) {
		
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
- (void)appendElement:(id <VIListElement>)element {
    [self insertElement:element afterElement:self.lastElement];
}
- (void)insertElement:(id <VIListElement>)element afterElement:(id <VIListElement>)preElement {
    if (!element) return;
    id <VIListElement> prev = preElement;
    id <VIListElement> next = preElement.next;
    if (!preElement) {
        prev = _firstElement.prev;
        next = _firstElement;
        _firstElement = element;
    }
    element.prev = prev;
    element.prev.next = element;
    element.next = next;
    element.next.prev = element;
    if (!_firstElement) {
		_firstElement = element;
	}
    self.closed = _closed;
    [self didAddElement:element];
}

- (void)didAddElement:(id<VIListElement>)element {
    if (!_elements) _elements = [[NSMutableArray alloc] init];
    [_elements addObject:element];
    [self.delegate list:self didAddElement:element];
}

#pragma mark Removing Elements

- (void)removeObject:(id)object {
    [self removeElement:[self elementForObject:object]];
}
- (void)removeElement:(id <VIListElement>)element {
	if (element==self.firstElement) _firstElement = _firstElement.next;
	if (element==self.currentElement) _currentElement = nil;
	element.prev.next = element.next;
	element.next.prev = element.prev;
    [self didRemoveElement:element];
}
- (void)removeAllElements {
	_firstElement = nil;
    _currentElement = nil;
    [self didRemoveAllElements];
}

- (void)didRemoveElement:(id<VIListElement>)element {
	[_elements removeObject:element];
    [self.delegate list:self didRemoveElement:element];
}
- (void)didRemoveAllElements {
	[_elements removeAllObjects];
    [self.delegate listDidRemoveAllElements:self];
}

#pragma mark Retrieving Elements

- (id <VIListElement>)lastElement {
	if (self.closed) return _firstElement.prev;
	return [_firstElement last];
}

- (id <VIListElement>)elementAtOffset:(int)offset {
	id <VIListElement> cu = self.currentElement;
	for (int i=0; i<offset; i++) {
		cu = cu.next;
	}
	return cu;
}

- (id <VIListElement>)elementAtIndex:(int)index {
    if (index<0||index>=[self count]) return nil;
	id <VIListElement> cu = self.firstElement;
	for (int i=0; i<index; i++) {
		cu = cu.next;
	}
	return cu;
}

- (NSUInteger)indexOfElement:(id <VIListElement>)element {
    if (!element) return 0; // TODO: throw exception & log error ?
	id <VIListElement> cu = self.firstElement;
	id <VIListElement> start = cu;
    NSUInteger index = 0;
	while (cu&&!(self.closed&&cu==start)) {
		if (cu==element) {
            return index;
        }
        cu = cu.next;
        index++;
    }
    return index;
}

- (id <VIListElement>)elementForObject:(id)object {
    if (!object) return nil;
	id <VIListElement> cu = self.firstElement;
	id <VIListElement> start = cu;
	while (cu&&!(self.closed&&cu==start)) {
		if (cu==object||([cu isKindOfClass:[VIListElement class]]&&[(VIListElement *)cu object]==object)) {
            return cu;
		}
		cu = cu.next;
	}
    return nil;
}

- (BOOL)containsElement:(id <VIListElement>)element {
    return [self elementForObject:element]!=nil;
}

- (NSUInteger)count {
    NSUInteger count = 0;
	id <VIListElement> cu = self.firstElement;
	id <VIListElement> start = cu;
	while (cu&&!(self.closed&&cu==start)) {
		count++;
		cu = cu.next;
	}
    return count;
}

#pragma mark Navigating

- (void)moveToFirst {
    _currentElement = self.firstElement;
}
- (void)moveToLast {
    _currentElement = self.lastElement;
}

- (id <VIListElement>)stepNext {
	id <VIListElement> cu = _currentElement;
	_currentElement = _currentElement.next;
	return cu;
}
- (id <VIListElement>)stepPrev {
	_currentElement = _currentElement.prev;
	return _currentElement;
}

#pragma mark More

- (void)setCurrentElement:(id <VIListElement>)currentElement {
    if (![self containsElement:currentElement]) return;
    _currentElement = currentElement;
}

- (void)shuffleElements {
    // TODO: make sure implementation works with managed object's automatic prev/next linking
    
    if (!_firstElement) return;
    
	id <VIListElement> preFirst = self.firstElement;
	id <VIListElement> newLast = nil;
	// pick random elements and move to new list
	id <VIListElement> cu;
	NSUInteger remaining = [self count];
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
    id <VIListElement> cu = (ascending)?self.firstElement:self.lastElement;
	id <VIListElement> start = cu;
    [orderedElements addObject:cu];
    while ((cu = (ascending)?cu.next:cu.prev)&&!(self.closed&&cu==start)) [orderedElements addObject:cu];
    return orderedElements;
}

@end
