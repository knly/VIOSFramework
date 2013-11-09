//
//  VIStack.h
//  pepa
//
//  Created by Nils Fischer on 24.04.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VIStackElement.h"

@interface VIStack : NSObject

- (VIStackElement *)top;
- (void)push:(VIStackElement *)element;
- (VIStackElement *)pop;
- (BOOL)isEmpty;
- (void)clear;

@end
