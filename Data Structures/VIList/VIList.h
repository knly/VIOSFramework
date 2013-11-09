//
//  VIList.h
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIListElement.h"

@interface VIList : NSObject;

@property (nonatomic, getter=isClosed) BOOL closed;

@property (weak, nonatomic, readonly) VIListElement *firstElement;
@property (weak, nonatomic, readonly) VIListElement *lastElement;
@property (weak, nonatomic) VIListElement *currentElement;

- (void)addObject:(id)object;
- (void)appendElement:(VIListElement *)element;
- (void)insertElement:(VIListElement *)element afterElement:(VIListElement *)preElement;
- (void)removeObject:(id)object;
- (void)removeElement:(VIListElement *)element;
- (void)removeAllElements;
- (VIListElement *)elementAtOffset:(int)offset;
- (VIListElement *)elementAtIndex:(int)index;
- (VIListElement *)elementForObject:(id)object;
- (BOOL)containsElement:(VIListElement *)element;
- (int)count;
- (void)moveToFirst;
- (void)moveToLast;

- (VIListElement *)stepNext;
- (VIListElement *)stepPrev;

- (void)shuffleElements;

- (NSArray *)orderedElementsAscending:(BOOL)ascending;

@end