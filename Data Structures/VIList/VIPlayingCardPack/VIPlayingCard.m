//
//  Card.m
//  21
//
//  Created by Nils Fischer on 09.04.11.
//  Copyright 2011 viWiD. All rights reserved.
//

#import "VIPlayingCard.h"
#import "VIPlayingCardPack.h"

@implementation VIPlayingCard

#pragma mark -
#pragma mark Lifecycle

- (id)initWithSuit:(uint)aSuit rank:(uint)aRank {
	if ((self = [super init])) {
		
		_suit = aSuit;
		_rank = aRank;
		
	}
	return self;
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)theDictionary {
    if ((self = [super init])) {
        _suit = [[theDictionary objectForKey:@"suit"] unsignedIntValue];
        _rank = [[theDictionary objectForKey:@"rank"] unsignedIntValue];
    }
    return self;
}

#pragma mark - Serialization

- (NSDictionary *)dictionaryRepresentation {
    return @{@"suit": @(_suit),
             @"rank": @(_rank)};
}

#pragma mark - Count Strategies

- (float)countForStrategy:(uint)aStrategy toCard:(VIPlayingCard *)endCard startingWith:(float)theCount {
    theCount += [VIPlayingCardPack valueForRank:_rank suit:_suit forStrategy:aStrategy];
    
    if (endCard==self||!self.next) {
        return theCount;
    } else {
        return [(VIPlayingCard *)self.next countForStrategy:aStrategy toCard:endCard startingWith:theCount];
    }
}

@end
