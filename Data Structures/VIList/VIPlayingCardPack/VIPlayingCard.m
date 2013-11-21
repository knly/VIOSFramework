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

#pragma mark - All Ranks & Suits

+ (NSArray *)allRanks {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt:kRank2],
            [NSNumber numberWithUnsignedInt:kRank3],
            [NSNumber numberWithUnsignedInt:kRank4],
            [NSNumber numberWithUnsignedInt:kRank5],
            [NSNumber numberWithUnsignedInt:kRank6],
            [NSNumber numberWithUnsignedInt:kRank7],
            [NSNumber numberWithUnsignedInt:kRank8],
            [NSNumber numberWithUnsignedInt:kRank9],
            [NSNumber numberWithUnsignedInt:kRank10],
            [NSNumber numberWithUnsignedInt:kRankJack],
            [NSNumber numberWithUnsignedInt:kRankQueen],
            [NSNumber numberWithUnsignedInt:kRankKing],
            [NSNumber numberWithUnsignedInt:kRankAce],
            nil];
}
+ (NSString *)symbolForRank:(uint)rank {
    switch (rank) {
        case kRank2: return @"2";
        case kRank3: return @"3";
        case kRank4: return @"4";
        case kRank5: return @"5";
        case kRank6: return @"6";
        case kRank7: return @"7";
        case kRank8: return @"8";
        case kRank9: return @"9";
        case kRank10: return @"10";
        case kRankJack: return @"J";
        case kRankQueen: return @"Q";
        case kRankKing: return @"K";
        case kRankAce: return @"A";
        default:
            break;
    }
    return nil;
}
+ (NSArray *)allSuits {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt:kSuitDiamonds],
            [NSNumber numberWithUnsignedInt:kSuitHearts],
            [NSNumber numberWithUnsignedInt:kSuitSpades],
            [NSNumber numberWithUnsignedInt:kSuitClubs],
            nil];
}

@end
