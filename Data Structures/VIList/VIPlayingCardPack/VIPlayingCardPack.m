//
//  Pack.m
//  21
//
//  Created by Nils Fischer on 09.04.11.
//  Copyright 2011 viWiD. All rights reserved.
//

#import "VIPlayingCardPack.h"

@interface VIPlayingCardPack ()

- (void)postUpdateNotification;

@end

@implementation VIPlayingCardPack

- (id)init {
	return [self initWithDictionaryRepresentation:nil];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)theDictionary {
    if ((self = [super init])) {
        
        if (!theDictionary) {
            
            self.packCount = 1;
            
            return self;
            
        }
        
        NSArray *orderedRepresentations = [theDictionary objectForKey:@"cards"];

        for (NSDictionary *cardRepresentation in orderedRepresentations) {
            VIPlayingCard *card = [[[self classForPlayingCards] alloc] initWithDictionaryRepresentation:cardRepresentation];
			[self appendElement:card];
        }
        
        self.currentElement = [self elementAtIndex:[[theDictionary objectForKey:@"top"] intValue]];
        
        _packCount = [[theDictionary objectForKey:@"packCount"] intValue];
        
        _showCover = [self isTop];
        
        [self postUpdateNotification];
        
    }
    return self;
}

#pragma mark - Serialization

- (NSDictionary *)dictionaryRepresentation {

    NSArray *orderedCards = [self orderedElementsAscending:YES];
    int topPosition = [orderedCards indexOfObject:self.top];
    
    NSMutableArray *orderedRepresentations = [[NSMutableArray alloc] init];
    for (VIPlayingCard *card in orderedCards) {
        [orderedRepresentations addObject:[card dictionaryRepresentation]];
    }
    
    return @{@"cards": orderedRepresentations,
             @"top": @(topPosition),
             @"packCount": @(_packCount)};
}

#pragma mark - Building a new Pack

- (void)buildPack {
	[self removeAllElements];
    
	if (_packCount<=0) return;
    
	for (int pack=0; pack<_packCount; pack++) {
		for (int suit=0; suit<4; suit++) {
			for (int rank=0; rank<13; rank++) {
				VIPlayingCard *card = [[[self classForPlayingCards] alloc] initWithSuit:suit rank:rank];
                [self appendElement:card];
			}
		}
	}
    
	[self moveToFirst];

    [self postUpdateNotification];
}

- (Class)classForPlayingCards {
    return [VIPlayingCard class];
}

#pragma mark - Pack Interaction

- (VIPlayingCard *)top {
    return (VIPlayingCard *)self.currentElement;
}

- (BOOL)isTop {
    return self.top==self.firstElement;
}

- (VIPlayingCard *)cardAtOffset:(int)offset {
	return (VIPlayingCard *)[self elementAtOffset:offset];
}

- (void)setPackCount:(int)count {
    if (count<=0) return;
    _packCount = count;
	[self buildPack];
    [self shuffle];
}

- (void)shuffle {
    [self shuffleElements];
    [self moveToFirst];
    [self postUpdateNotification];
}

- (VIPlayingCard *)draw {
    return [self draw:1];
}

- (VIPlayingCard *)draw:(int)count {
	VIPlayingCard *cu = self.top;
    if (!cu) return cu;
    if (_showCover) _showCover = NO;
    else {
        for (int i=0; i<count; i++) {
            cu = (VIPlayingCard *)[self stepNext];
        }
    }
	[self postUpdateNotification];
	return cu;
}

- (VIPlayingCard *)remit {
    return [self remit:1];
}

- (VIPlayingCard *)remit:(int)count {
	VIPlayingCard *cu = self.top;
    if (!cu) {
        self.currentElement = [self lastElement];
        cu = self.top;
        count -= 1;
    }
    for (int i=0; i<count; i++) {
        if (cu.prev) cu = (VIPlayingCard *)[self stepPrev];
        else break;
    }
	[self postUpdateNotification];
	return cu;
}

- (void)moveToFirst {
    _showCover = YES;
    [super moveToFirst];
}

#pragma mark - Update Notification

- (void)postUpdateNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:VIPackDidChangeNotification object:self];
}

@end
