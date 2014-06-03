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

@synthesize progressTintColor = _progressTintColor;
@synthesize trackTintColor = _trackTintColor;

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
    
    self.showText = YES;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat startAngle = self.startAngle;
    CGFloat endAngle = 2 * M_PI * self.progress + self.startAngle;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat lineWidth = self.lineWidth;
    CGFloat outerRadius = MIN(rect.size.width/2., rect.size.height/2.);
    CGFloat innerRadius = outerRadius - lineWidth;
    CGFloat radius = outerRadius - lineWidth / 2.;
    // CGRect outerCircleRect = CGRectMake(center.x - outerRadius, center.y - outerRadius, 2 * outerRadius, 2 * outerRadius);
    CGRect innerCircleRect = CGRectMake(center.x - innerRadius, center.y - innerRadius, 2 * innerRadius, 2 * innerRadius);
    
    // Image
    UIImage *image = self.image;
    if (image) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(innerCircleRect, -1, -1)] addClip];
        [image drawInRect:CGRectInset(innerCircleRect, -1, -1)];
        CGContextRestoreGState(context);
    }

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
    if (self.showText) {
        NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
        if (!attributedText && self.text) attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
        if (!attributedText) attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%%", (int)roundf(self.progress*100)]];
        CGRect textRect = [attributedText boundingRectWithSize:innerCircleRect.size options:0 context:nil];
        [attributedText drawInRect:CGRectMake(innerCircleRect.origin.x + innerCircleRect.size.width / 2. - textRect.size.width / 2., innerCircleRect.origin.y + innerCircleRect.size.height / 2. - textRect.size.height / 2., textRect.size.width, textRect.size.height)];
    }
}

- (UIColor *)progressTintColor
{
    if (!_progressTintColor) return self.tintColor;
    return _progressTintColor;
}

- (UIColor *)trackTintColor
{
    if (!_trackTintColor) return [UIColor colorWithWhite:0.9 alpha:1];
    return _trackTintColor;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = startAngle;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    [self setNeedsDisplay];
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    _text = text;
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    self.text = attributedText.string;
    [self setNeedsDisplay];
}

- (void)setShowText:(BOOL)showText {
    _showText = showText;
    [self setNeedsDisplay];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self setNeedsDisplay];
}

@end
