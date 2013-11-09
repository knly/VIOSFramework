//
//  Card.h
//  21
//
//  Created by Nils Fischer on 09.04.11.
//  Copyright 2011 viWiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIListElement.h"

@interface VIPlayingCard : VIListElement

@property (nonatomic, readonly) uint suit;
@property (nonatomic, readonly) uint rank;

- (id)initWithSuit:(uint)aSuit rank:(uint)aRank;
- (id)initWithDictionaryRepresentation:(NSDictionary *)theDictionary;
- (NSDictionary *)dictionaryRepresentation;

- (float)countForStrategy:(uint)aStrategy toCard:(VIPlayingCard *)endCard startingWith:(float)theCount;

@end
