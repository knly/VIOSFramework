//
//  Pack.h
//  21
//
//  Created by Nils Fischer on 09.04.11.
//  Copyright 2011 viWiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIList.h"
#import "VIPlayingCard.h"

#define VIPackDidChangeNotification @"VIPackDidChangeNotification"

#define VIPlayingCardPackDisableIRCSubtraction @"VIPlayingCardPackDisableIRCSubtraction"

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

enum Strategies {
    kStrategyCount,
	kStrategyHiLo,
    kStrategyREKO,
    kStrategyZenCount,
    kStrategyCanfieldExpert,
    kStrategyCanfieldMaster,
    kStrategyHiOpt1,
    kStrategyHiOpt2,
    kStrategyKiss2,
    kStrategyKiss3,
    kStrategyKO,
    kStrategyMentor,
    kStrategyOmega2,
    kStrategyRedSeven,
    kStrategyReverePlusMinus,
    kStrategyReverePointCount,
    kStrategyRevereRAPC,
    kStrategyRevere14Count,
    kStrategySilverFox,
    kStrategyUnbalancedZen2,
    kStrategyUstonAdvPlusMinus,
    kStrategyUstonAPC,
    kStrategyUstonSS,
    kStrategyWongHalves
};

@interface VIPlayingCardPack : VIList

@property (nonatomic) int packCount;

@property (nonatomic) BOOL showCover;

@property (nonatomic, readonly) NSTimeInterval countingTime;

- (id)initWithDictionaryRepresentation:(NSDictionary *)theDictionary;
- (NSDictionary *)dictionaryRepresentation;

- (VIPlayingCard *)top;
- (BOOL)isTop;
- (VIPlayingCard *)cardAtOffset:(int)offset;

- (void)shuffle;
- (VIPlayingCard *)draw;
- (VIPlayingCard *)draw:(int)count;
- (VIPlayingCard *)remit;
- (VIPlayingCard *)remit:(int)count;

- (void)startCountingTimer;
- (void)stopCountingTimer;
- (void)resetCountingTimer;

- (float)countForStrategy:(uint)aStrategy fromCard:(VIPlayingCard *)startCard toCard:(VIPlayingCard *)endCard trueCount:(BOOL)isTrueCount;

+ (NSArray *)allRanks;
+ (NSString *)symbolForRank:(uint)rank;
+ (NSArray *)allSuits;

+ (NSArray *)allStrategies;
+ (NSDictionary *)infoForStrategy:(uint)aStrategy;
+ (float)valueForRank:(uint)aRank suit:(uint)aSuit forStrategy:(uint)aStrategy;

@end
