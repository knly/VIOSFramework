//
//  VICircularProgressView.m
//  living
//
//  Created by Nils Fischer on 27.05.14.
//  Copyright (c) 2014 viWiD Webdesign & iOS Development. All rights reserved.
//

#import "VICircularProgressView.h"


@interface VICircularProgressView ()

@end


@implementation VICircularProgressView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}
- (void)initialize
{
    self.progress = 0.5;

    self.startAngle = -M_PI_2;
    self.lineWidth = 5;
    
    self.textAlignment = NSTextAlignmentCenter;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat startAngle = self.startAngle;
    CGFloat endAngle = 2 * M_PI * self.progress + self.startAngle;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius = MIN(rect.size.width/2., rect.size.height/2.) - self.lineWidth / 2.;
    
    // Progress bar
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:center
                          radius:radius
                      startAngle:startAngle
                        endAngle:endAngle
                       clockwise:YES];
    progressPath.lineWidth = self.lineWidth;
    [self.progressTintColor setStroke];
    [progressPath stroke];

    // Track
    UIBezierPath *trackPath = [UIBezierPath bezierPath];
    [trackPath addArcWithCenter:center
                          radius:radius
                      startAngle:startAngle
                        endAngle:endAngle
                       clockwise:NO];
    trackPath.lineWidth = self.lineWidth;
    [self.trackTintColor setStroke];
    [trackPath stroke];
    
    // Text
    [super drawTextInRect:rect];
}

- (UIColor *)progressTintColor
{
    if (!_progressTintColor) return self.tintColor;
    return _progressTintColor;
}

- (UIColor *)trackTintColor
{
    if (!_trackTintColor) return [UIColor colorWithWhite:0.9 alpha:1];
    return _progressTintColor;
}

@end
