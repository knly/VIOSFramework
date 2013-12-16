//
//  VIList.h
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIListElement.h"

@protocol VIListDelegate;

@interface VIList : NSObject

@property (nonatomic, getter=isClosed) BOOL closed;

@property (weak, nonatomic) id <VIListElement> firstElement;
@property (weak, nonatomic, readonly) id <VIListElement> lastElement;
@property (weak, nonatomic) id <VIListElement> currentElement;

@property (weak, nonatomic) id <VIListDelegate> delegate;

- (void)addObject:(id)object; // convenience method

- (void)appendElement:(id <VIListElement>)element;
- (void)insertElement:(id <VIListElement>)element afterElement:(id <VIListElement>)preElement;
- (void)removeObject:(id)object;
- (void)removeElement:(id <VIListElement>)element;
- (void)removeAllElements;

- (id <VIListElement>)elementAtOffset:(int)offset;
- (id <VIListElement>)elementAtIndex:(int)index;
- (NSUInteger)indexOfElement:(id <VIListElement>)element;
- (id <VIListElement>)elementForObject:(id)object;
- (BOOL)containsElement:(id <VIListElement>)element;
- (NSUInteger)count;

- (void)moveToFirst;
- (void)moveToLast;

- (id <VIListElement>)stepNext;
- (id <VIListElement>)stepPrev;

- (void)shuffleElements;

- (NSArray *)orderedElementsAscending:(BOOL)ascending;

@end

@protocol VIListDelegate

- (void)list:(VIList *)list didAddElement:(id <VIListElement>)element;
- (void)list:(VIList *)list didRemoveElement:(id <VIListElement>)element;
- (void)listDidRemoveAllElements:(VIList *)list;

@end