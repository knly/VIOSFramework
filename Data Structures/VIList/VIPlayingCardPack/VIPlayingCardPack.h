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

@interface VIPlayingCardPack : VIList

@property (nonatomic) int packCount;

@property (nonatomic) BOOL showCover;

- (id)initWithDictionaryRepresentation:(NSDictionary *)theDictionary;
- (NSDictionary *)dictionaryRepresentation;

- (void)buildPack;
- (Class)classForPlayingCards;
- (VIPlayingCard *)top;
- (BOOL)isTop;
- (VIPlayingCard *)cardAtOffset:(int)offset;

- (void)shuffle;
- (VIPlayingCard *)draw;
- (VIPlayingCard *)draw:(int)count;
- (VIPlayingCard *)remit;
- (VIPlayingCard *)remit:(int)count;

@end
