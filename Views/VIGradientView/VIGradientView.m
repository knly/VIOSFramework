//
//  VIShadedBackgroundView.m
//  21
//
//  Created by Nils Fischer on 02.11.13.
//
//

#import "VIGradientView.h"

#define VIGradientViewShadowOpacity 0.25

@interface VIGradientView ()

- (void)setupLayer;

@end

@implementation VIGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupLayer];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
    }
    return self;
}

- (void)setupLayer {
    self.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradient = self.layer;
    gradient.frame = self.bounds;
    gradient.colors = @[(id)[[UIColor colorWithWhite:0 alpha:VIGradientViewShadowOpacity] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0 alpha:VIGradientViewShadowOpacity] CGColor]];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1., 0);
}

@end
