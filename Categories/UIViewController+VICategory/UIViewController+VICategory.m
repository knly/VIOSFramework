//
//  UIViewController+UIViewController_VICategory.m
//  pepa
//
//  Created by Nils Fischer on 13.03.13.
//  Copyright (c) 2013 MSK2Media. All rights reserved.
//

#import "UIViewController+VICategory.h"

@implementation UIViewController (VICategory)

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
