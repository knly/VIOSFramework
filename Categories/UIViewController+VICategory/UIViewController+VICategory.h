//
//  UIViewController+UIViewController_VICategory.h
//  pepa
//
//  Created by Nils Fischer on 13.03.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface UIViewController (VICategory)

- (AppDelegate *)appDelegate;

- (IBAction)doneButtonPressed:(id)sender;

@end
