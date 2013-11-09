//
//  VIListElement.h
//  21
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 viWiD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIDataStructureElement.h"

@interface VIListElement : VIDataStructureElement

@property (weak, nonatomic) VIListElement *prev;
@property (weak, nonatomic) VIListElement *next;

- (VIListElement *)first;
- (VIListElement *)last;

@end