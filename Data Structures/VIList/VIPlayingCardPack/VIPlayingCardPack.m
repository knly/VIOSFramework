//
//  Pack.m
//  21
//
//  Created by Nils Fischer on 09.04.11.
//  Copyright 2011 viWiD. All rights reserved.
//

#import "VIPlayingCardPack.h"

@interface VIPlayingCardPack ()

@property (nonatomic) NSTimeInterval beginCountingTimestamp;
@property (nonatomic) NSTimeInterval totalCountingTime;

- (void)buildPack;

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
            VIPlayingCard *card = [[VIPlayingCard alloc] initWithDictionaryRepresentation:cardRepresentation];
			[self appendElement:card];
        }
        
        self.currentElement = [self elementAtIndex:[[theDictionary objectForKey:@"top"] intValue]];
        
        _packCount = [[theDictionary objectForKey:@"packCount"] intValue];

        _totalCountingTime = [[theDictionary objectForKey:@"totalCountingTime"] doubleValue];
        
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
             @"packCount": @(_packCount),
             @"totalCountingTime": @(_totalCountingTime)};
}

#pragma mark - Building a new Pack

- (void)buildPack {
    [self resetCountingTimer];

	[self removeAllElements];
    
	if (_packCount<=0) return;
    
	for (int pack=0; pack<_packCount; pack++) {
		for (int suit=0; suit<4; suit++) {
			for (int rank=0; rank<13; rank++) {
				VIPlayingCard *card = [[VIPlayingCard alloc] initWithSuit:suit rank:rank];
                [self appendElement:card];
			}
		}
	}
    
	[self moveToFirst];

    [self postUpdateNotification];
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
    [self resetCountingTimer];
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
    if (cu.next) [self startCountingTimer];
    else [self stopCountingTimer];
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

#pragma mark - Counting Timer

- (void)startCountingTimer {
    if (self.beginCountingTimestamp!=0||self.showCover) return;
    self.beginCountingTimestamp = [NSDate timeIntervalSinceReferenceDate];
}

- (void)stopCountingTimer {
    if (self.beginCountingTimestamp==0) return;
    self.totalCountingTime = self.countingTime;
    self.beginCountingTimestamp = 0;
}

- (void)resetCountingTimer {
    [self stopCountingTimer];
    self.totalCountingTime = 0;
}

- (NSTimeInterval)countingTime {
    if (self.beginCountingTimestamp==0) return self.totalCountingTime;
    return self.totalCountingTime + ([NSDate timeIntervalSinceReferenceDate]-self.beginCountingTimestamp);
}

#pragma mark - Update Notification

- (void)postUpdateNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:VIPackDidChangeNotification object:self];
}

#pragma #pragma mark - Count Strategies

- (float)countForStrategy:(uint)aStrategy fromCard:(VIPlayingCard *)startCard toCard:(VIPlayingCard *)endCard trueCount:(BOOL)isTrueCount {

    if (!startCard) startCard = (VIPlayingCard *)self.firstElement;
    
    float theCount = [startCard countForStrategy:aStrategy toCard:endCard startingWith:0];

    if (self.showCover) theCount = 0;
    
    NSDictionary *strategyInfo = [VIPlayingCardPack infoForStrategy:aStrategy];
    BOOL isBalanced = [[strategyInfo objectForKey:@"type"] isEqualToString:@"B"];

    if (!isBalanced&&![[NSUserDefaults standardUserDefaults] boolForKey:@"VIPlayingCardPackDisableIRCSubtraction"]) {
        // subtract IRC with unbalanced strategies
        theCount = theCount - (self.packCount - [[strategyInfo objectForKey:@"irc_pack_offset"] intValue]) * [[strategyInfo objectForKey:@"netUnbalance"] floatValue];
    }

    if (isTrueCount) {

        float remainingPacks = (self.packCount-([startCard countForStrategy:kStrategyCount toCard:endCard startingWith:0]/(13.*4.)));
        if (remainingPacks==0) return 0;
        return theCount/remainingPacks;

    }

    return theCount;
}

#pragma mark - Strategy Information

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

#pragma mark - Count Strategies
+ (NSArray *)allStrategies {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithUnsignedInt:kStrategyHiLo],
            [NSNumber numberWithUnsignedInt:kStrategyREKO],
            [NSNumber numberWithUnsignedInt:kStrategyZenCount],
            [NSNumber numberWithUnsignedInt:kStrategyCanfieldExpert],
            [NSNumber numberWithUnsignedInt:kStrategyCanfieldMaster],
            [NSNumber numberWithUnsignedInt:kStrategyHiOpt1],
            [NSNumber numberWithUnsignedInt:kStrategyHiOpt2],
            [NSNumber numberWithUnsignedInt:kStrategyKiss2],
            [NSNumber numberWithUnsignedInt:kStrategyKiss3],
            [NSNumber numberWithUnsignedInt:kStrategyKO],
            [NSNumber numberWithUnsignedInt:kStrategyMentor],
            [NSNumber numberWithUnsignedInt:kStrategyOmega2],
            [NSNumber numberWithUnsignedInt:kStrategyRedSeven],
            [NSNumber numberWithUnsignedInt:kStrategyReverePlusMinus],
            [NSNumber numberWithUnsignedInt:kStrategyReverePointCount],
            [NSNumber numberWithUnsignedInt:kStrategyRevereRAPC],
            [NSNumber numberWithUnsignedInt:kStrategyRevere14Count],
            [NSNumber numberWithUnsignedInt:kStrategySilverFox],
            [NSNumber numberWithUnsignedInt:kStrategyUnbalancedZen2],
            [NSNumber numberWithUnsignedInt:kStrategyUstonAdvPlusMinus],
            [NSNumber numberWithUnsignedInt:kStrategyUstonAPC],
            [NSNumber numberWithUnsignedInt:kStrategyUstonSS],
            [NSNumber numberWithUnsignedInt:kStrategyWongHalves],
            nil];
}

+ (NSDictionary *)infoForStrategy:(uint)aStrategy {
	
	NSDictionary *strategyInfo = [[NSDictionary alloc] init];
    
    switch (aStrategy) {
        case kStrategyHiLo:
			strategyInfo = @{
					@"title": @"Hi-Lo",
	 @"ease": @"6",
	 @"bc": @".97",
	 @"pe": @".51",
	 @"ic": @".76",
	 @"key": @"hi_lo"
	 };
			break;
        case kStrategyREKO:
            strategyInfo = @{
							 @"title": @"REKO",
		@"ease": @"8",
		@"bc": @".98",
		@"pe": @".55",
		@"ic": @".78",
		@"key": @"reko"
		};
			break;
        case kStrategyZenCount:
            strategyInfo = @{
							 @"title": @"Zen Count",
		@"ease": @"4",
		@"bc": @".96",
		@"pe": @".63",
		@"ic": @".85",
		@"key": @"zenCount"
		};
			break;
        case kStrategyCanfieldExpert:
            strategyInfo = @{
							 @"title": @"Canfield Expert",
		@"ease": @"6",
		@"bc": @".87",
		@"pe": @".63",
		@"ic": @".76",
		@"key": @"canfield_expert"
		};
			break;
        case kStrategyCanfieldMaster:
            strategyInfo = @{
							 @"title": @"Canfield Master",
		@"ease": @"4",
		@"bc": @".92",
		@"pe": @".67",
		@"ic": @".85",
		@"key": @"canfield_master"
		};
			break;
        case kStrategyHiOpt1:
            strategyInfo = @{
							 @"title": @"Hi-Opt I",
		@"ease": @"6.5",
		@"bc": @".88",
		@"pe": @".61",
		@"ic": @".85",
		@"key": @"hi_opt_1"
		};
			break;
        case kStrategyHiOpt2:
            strategyInfo = @{
							 @"title": @"Hi-Opt II",
		@"ease": @"4",
		@"bc": @".91",
		@"pe": @".67",
		@"ic": @".91",
		@"key": @"hi_opt_2"
		};
			break;
        case kStrategyKiss2:
            strategyInfo = @{
							 @"title": @"KISS 2",
		@"ease": @"7",
		@"bc": @".90",
		@"pe": @".62",
		@"ic": @".87",
		@"key": @"kiss_2"
		};
			break;
        case kStrategyKiss3:
            strategyInfo = @{
							 @"title": @"KISS 3",
		@"ease": @"7",
		@"bc": @".98",
		@"pe": @".56",
		@"ic": @".78",
		@"key": @"kiss_3"
		};
			break;
        case kStrategyKO:
            strategyInfo = @{
							 @"title": @"K-O",
		@"ease": @"7.5",
		@"bc": @".98",
		@"pe": @".55",
		@"ic": @".78",
		@"key": @"k_o",
        @"irc_pack_offset": @(1)
		};
			break;
        case kStrategyMentor:
            strategyInfo = @{
							 @"title": @"Mentor",
		@"ease": @"4",
		@"bc": @".97",
		@"pe": @".62",
		@"ic": @".80",
		@"key": @"mentor"
		};
			break;
        case kStrategyOmega2:
            strategyInfo = @{
							 @"title": @"Omega II",
		@"ease": @"4",
		@"bc": @".92",
		@"pe": @".67",
		@"ic": @".85",
		@"key": @"omega_2"
		};
			break;
        case kStrategyRedSeven:
            strategyInfo = @{
							 @"title": @"Red Seven",
		@"ease": @"7",
		@"bc": @".98",
		@"pe": @".54",
		@"ic": @".78",
		@"key": @"red_seven"
		};
			break;
        case kStrategyReverePlusMinus:
            strategyInfo = @{
							 @"title": @"Revere Plus-Minus",
		@"ease": @"6",
		@"bc": @".89",
		@"pe": @".59",
		@"ic": @".76",
		@"key": @"revere_plus_minus"
		};
			break;
        case kStrategyReverePointCount:
            strategyInfo = @{
							 @"title": @"Revere Point Count",
		@"ease": @"4",
		@"bc": @".99",
		@"pe": @".55",
		@"ic": @".78",
		@"key": @"revere_point_count"
		};
			break;
        case kStrategyRevereRAPC:
            strategyInfo = @{
							 @"title": @"Revere RAPC",
		@"ease": @"1",
		@"bc": @"1.0",
		@"pe": @".53",
		@"ic": @".71",
		@"key": @"revere_rapc"
		};
			break;
        case kStrategyRevere14Count:
            strategyInfo = @{
							 @"title": @"Revere 14 Count",
		@"ease": @"1",
		@"bc": @".92",
		@"pe": @".65",
		@"ic": @".82",
		@"key": @"revere_14_count"
		};
			break;
        case kStrategySilverFox:
            strategyInfo = @{
							 @"title": @"Silver Fox",
		@"ease": @"6",
		@"bc": @".96",
		@"pe": @".53",
		@"ic": @".69",
		@"key": @"silver_fox"
		};
			break;
        case kStrategyUnbalancedZen2:
            strategyInfo = @{
							 @"title": @"Unbalanced Zen 2",
		@"ease": @"6.5",
		@"bc": @".97",
		@"pe": @".62",
		@"ic": @".84",
		@"key": @"unbalanced_zen_2"
		};
			break;
        case kStrategyUstonAdvPlusMinus:
            strategyInfo = @{
							 @"title": @"Uston Adv. Plus-Minus",
		@"ease": @"6.5",
		@"bc": @".95",
		@"pe": @".55",
		@"ic": @".76",
		@"key": @"uston_adv_plus_minus"
		};
			break;
        case kStrategyUstonAPC:
            strategyInfo = @{
							 @"title": @"Uston APC",
		@"ease": @"2.5",
		@"bc": @".91",
		@"pe": @".69",
		@"ic": @".90",
		@"key": @"uston_apc"
		};
			break;
        case kStrategyUstonSS:
            strategyInfo = @{
							 @"title": @"Uston SS",
		@"ease": @"4.5",
		@"bc": @".99",
		@"pe": @".54",
		@"ic": @".73",
		@"key": @"uston_ss"
		};
			break;
        case kStrategyWongHalves:
            strategyInfo = @{
							 @"title": @"Wong Halves",
		@"ease": @"2.5",
		@"bc": @".99",
		@"pe": @".56",
		@"ic": @".72",
		@"key": @"wrong_halves"
		};
			break;
        default:
			break;
}

    NSMutableDictionary *mutableStrategyInfo = [strategyInfo mutableCopy];

    NSArray *allRanks = [VIPlayingCardPack allRanks];
    NSArray *allSuits = [VIPlayingCardPack allSuits];

    // level, type
    NSMutableDictionary *distinctValues = [[NSMutableDictionary alloc] init];
    float valueSum = 0;
    for (NSNumber *aRank in allRanks) {
        for (NSNumber *aSuit in allSuits) {
            
            float theValue = [VIPlayingCardPack valueForRank:[aRank unsignedIntValue] suit:[aSuit unsignedIntValue] forStrategy:aStrategy];
            
            if (theValue!=0) [distinctValues setObject:[NSNull null] forKey:[NSString stringWithFormat:@"%.1f",fabsf(theValue)]];
            
            valueSum += theValue;
            
            NSString *theValKey = [NSString stringWithFormat:@"val%i",[aRank unsignedIntValue]];
            NSString *theValString = (roundf(theValue)==theValue)?[NSString stringWithFormat:@"%i",(int)(roundf(theValue))]:[NSString stringWithFormat:@"%.1f",theValue];
            if ([mutableStrategyInfo objectForKey:theValKey]) {
                if ([[[[mutableStrategyInfo objectForKey:theValKey] componentsSeparatedByString:@"/"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self LIKE[cd] %@",theValString]] count]==0) theValString = [(NSString *)[mutableStrategyInfo objectForKey:theValKey] stringByAppendingFormat:@"/%@",theValString];
                else theValString = [mutableStrategyInfo objectForKey:theValKey];
            }
            [mutableStrategyInfo setObject:theValString forKey:theValKey];
            
        }
    }
    [mutableStrategyInfo setObject:[NSString stringWithFormat:@"%i",[distinctValues count]] forKey:@"level"];
    [mutableStrategyInfo setObject:(valueSum==0)?@"B":@"U" forKey:@"type"];
    [mutableStrategyInfo setObject:@(valueSum) forKey:@"netUnbalance"];

    return mutableStrategyInfo;
}

+ (float)valueForRank:(uint)aRank suit:(uint)aSuit forStrategy:(uint)aStrategy {
    switch (aStrategy) {
            
        case kStrategyCount:
            return 1;
            
        case kStrategyHiLo:
            switch (aRank) {
                case kRank2:
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                    return 1;
                case kRank7:
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyREKO:
            switch (aRank) {
                case kRank2:
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                case kRank7:
                    return 1;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyZenCount:
            switch (aRank) {
                case kRank2:
                case kRank3:
                    return 1;
                case kRank4:
                case kRank5:
                case kRank6:
                    return 2;
                case kRank7:
                    return 1;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -2;
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyCanfieldExpert:
            switch (aRank) {
                case kRank2:
                    return 0;
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                case kRank7:
                    return 1;
                case kRank8:
                    return 0;
                case kRank9:
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -1;
                case kRankAce:
                    return 0;
                default:
                    return 0;
            }
            
        case kStrategyCanfieldMaster:
            switch (aRank) {
                case kRank2:
                case kRank3:
                    return 1;
                case kRank4:
                case kRank5:
                case kRank6:
                    return 2;
                case kRank7:
                    return 1;
                case kRank8:
                    return 0;
                case kRank9:
                    return -1;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -2;
                case kRankAce:
                    return 0;
                default:
                    return 0;
            }
            
        case kStrategyHiOpt1:
            switch (aRank) {
                case kRank2:
                    return 0;
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                    return 1;
                case kRank7:
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -1;
                case kRankAce:
                    return 0;
                default:
                    return 0;
            }
            
        case kStrategyHiOpt2:
            switch (aRank) {
                case kRank2:
                case kRank3:
                    return 1;
                case kRank4:
                case kRank5:
                    return 2;
                case kRank6:
                case kRank7:
                    return 1;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -2;
                case kRankAce:
                    return 0;
                default:
                    return 0;
            }            
            
        case kStrategyKiss2:
            switch (aRank) {
                case kRank2:
                    return (aSuit==kSuitDiamonds||aSuit==kSuitHearts)?0:1;
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                    return 1;
                case kRank7:
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -1;
                case kRankAce:
                    return 0;
                default:
                    return 0;
            }
            
        case kStrategyKiss3:
            switch (aRank) {
                case kRank2:
                    return (aSuit==kSuitDiamonds||aSuit==kSuitHearts)?0:1;
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                case kRank7:
                    return 1;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyKO:
            switch (aRank) {
                case kRank2:
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                case kRank7:
                    return 1;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyMentor:
            switch (aRank) {
                case kRank2:
                    return 1;
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                    return 2;
                case kRank7:
                    return 1;
                case kRank8:
                    return 0;
                case kRank9:
                    return -1;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -2;
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyOmega2:
            switch (aRank) {
                case kRank2:
                case kRank3:
                    return 1;
                case kRank4:
                case kRank5:
                case kRank6:
                    return 2;
                case kRank7:
                    return 1;
                case kRank8:
                    return 0;
                case kRank9:
                    return -1;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -2;
                case kRankAce:
                    return 0;
                default:
                    return 0;
            }
            
        case kStrategyRedSeven:
            switch (aRank) {
                case kRank2:
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                    return 1;
                case kRank7:
                    return (aSuit==kSuitDiamonds||aSuit==kSuitHearts)?1:0;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyReverePlusMinus:
            switch (aRank) {
                case kRank2:
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                    return 1;
                case kRank7:
                case kRank8:
                    return 0;
                case kRank9:
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -1;
                case kRankAce:
                    return 0;
                default:
                    return 0;
            }
            
        case kStrategyReverePointCount:
            switch (aRank) {
                case kRank2:
                    return 1;
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                    return 2;
                case kRank7:
                    return 1;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -2;
                default:
                    return 0;
            }
            
        case kStrategyRevereRAPC:
            switch (aRank) {
                case kRank2:
                    return 2;
                case kRank3:
                case kRank4:
                    return 3;
                case kRank5:
                    return 4;
                case kRank6:
                    return 3;
                case kRank7:
                    return 2;
                case kRank8:
                    return 0;
                case kRank9:
                    return -1;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -3;
                case kRankAce:
                    return -4;
                default:
                    return 0;
            }
            
        case kStrategyRevere14Count:
            switch (aRank) {
                case kRank2:
                case kRank3:
                    return 2;
                case kRank4:
                    return 3;
                case kRank5:
                    return 4;
                case kRank6:
                    return 2;
                case kRank7:
                    return 1;
                case kRank8:
                    return 0;
                case kRank9:
                    return -2;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -3;
                case kRankAce:
                default:
                    return 0;
            }
            
        case kStrategySilverFox:
            switch (aRank) {
                case kRank2:
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                case kRank7:
                    return 1;
                case kRank8:
                    return 0;
                case kRank9:
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyUnbalancedZen2:
            switch (aRank) {
                case kRank2:
                    return 1;
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                    return 2;
                case kRank7:
                    return 1;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -2;
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyUstonAdvPlusMinus:
            switch (aRank) {
                case kRank2:
                    return 0;
                case kRank3:
                case kRank4:
                case kRank5:
                case kRank6:
                case kRank7:
                    return 1;
                case kRank8:
                case kRank9:
                    return 0;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }
            
        case kStrategyUstonAPC:
            switch (aRank) {
                case kRank2:
                    return 1;
                case kRank3:
                case kRank4:
                    return 2;
                case kRank5:
                    return 3;
                case kRank6:
                case kRank7:
                    return 2;
                case kRank8:
                    return 1;
                case kRank9:
                    return -1;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                    return -3;
                case kRankAce:
                default:
                    return 0;
            }
            
        case kStrategyUstonSS:
            switch (aRank) {
                case kRank2:
                case kRank3:
                case kRank4:
                    return 2;
                case kRank5:
                    return 3;
                case kRank6:
                    return 2;
                case kRank7:
                    return 1;
                case kRank8:
                    return 0;
                case kRank9:
                    return -1;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -2;
                default:
                    return 0;
            }
            
        case kStrategyWongHalves:
            switch (aRank) {
                case kRank2:
                    return 0.5;
                case kRank3:
                case kRank4:
                    return 1;
                case kRank5:
                    return 1.5;
                case kRank6:
                    return 1;
                case kRank7:
                    return 0.5;
                case kRank8:
                    return 0;
                case kRank9:
                    return -0.5;
                case kRank10:
                case kRankJack:
                case kRankQueen:
                case kRankKing:
                case kRankAce:
                    return -1;
                default:
                    return 0;
            }

        default:
            break;
    }
    return 0;
}


@end
