//
//  VICircularProgressView.h
//  living
//
//  Created by Nils Fischer on 27.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VICircularProgressView : UIView

@property (nonatomic) CGFloat progress;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat lineWidth;

@property (strong, nonatomic) UIColor *progressTintColor;
@property (strong, nonatomic) UIColor *trackTintColor;

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSAttributedString *attributedText;
@property (nonatomic) BOOL showText;

@property (strong, nonatomic) UIImage *image;

@end
