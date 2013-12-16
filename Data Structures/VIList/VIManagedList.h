//
//  VIManagedList.h
//  card
//
//  Created by Nils Fischer on 15.12.13.
//  Copyright (c) 2013 Nils Fischer. All rights reserved.
//

#import "VIList.h"

@interface VIManagedList : VIList

@property (nonatomic, strong) NSMutableOrderedSet *orderedSet;

@end
