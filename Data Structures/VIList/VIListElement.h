//
//  VIListElement.h
//  21
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 viWiD. All rights reserved.
//

@import Foundation;

#import "VIDataStructureElement.h"

@class VIListElement;

@protocol VIListElement <VIDataStructureElement>

@property (weak, nonatomic) id <VIListElement> prev;
@property (weak, nonatomic) id <VIListElement> next;

- (id <VIListElement>)first;
- (id <VIListElement>)last;

@end

@interface VIListElement : VIDataStructureElement <VIListElement>

@end