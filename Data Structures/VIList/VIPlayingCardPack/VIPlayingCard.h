//
//  Card.h
//  21
//
//  Created by Nils Fischer on 09.04.11.
//  Copyright 2011 viWiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIListElement.h"

enum suits {
	kSuitDiamonds,
	kSuitHearts,
	kSuitSpades,
	kSuitClubs
};

enum ranks {
	kRank2,
	kRank3,
	kRank4,
	kRank5,
	kRank6,
	kRank7,
	kRank8,
	kRank9,
	kRank10,
	kRankJack,
	kRankQueen,
	kRankKing,
	kRankAce
};

@interface VIPlayingCard : NSObject <VIListElement>

@property (nonatomic, readonly) uint suit;
@property (nonatomic, readonly) uint rank;

- (id)initWithSuit:(uint)aSuit rank:(uint)aRank;
- (id)initWithDictionaryRepresentation:(NSDictionary *)theDictionary;
- (NSDictionary *)dictionaryRepresentation;

+ (VIPlayingCard *)playingCardWithSuit:(uint)aSuit rank:(uint)aRank;

+ (NSArray *)allRanks;
+ (NSString *)symbolForSuit:(uint)suit;
+ (NSString *)symbolForRank:(uint)rank;
+ (NSArray *)allSuits;

@end
