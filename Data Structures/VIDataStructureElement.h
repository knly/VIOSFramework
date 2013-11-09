//
//  VIDataStructureElement.h
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VIDataStructureElement : NSObject

@property (strong, nonatomic) id object;
@property (strong, nonatomic) id secondaryObject;

+ (id)elementWithObject:(id)object;

@end
