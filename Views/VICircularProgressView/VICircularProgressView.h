//
//  VICircularProgressView.h
//  living
//
//  Created by Nils Fischer on 27.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VICircularProgressView : UILabel

@property (nonatomic) CGFloat progress;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat lineWidth;

@property (strong, nonatomic) UIColor *progressTintColor;
@property (strong, nonatomic) UIColor *trackTintColor;

@end
