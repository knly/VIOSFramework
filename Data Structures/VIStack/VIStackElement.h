//
//  VIStackElement.h
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIDataStructureElement.h"

@interface VIStackElement : VIDataStructureElement

@property (weak, nonatomic) VIStackElement *prev;

@end
