//
//  VIImageOverlayRenderer.m
//  uni-hd
//
//  Created by Andreas Schachner on 03.09.14.
//  Copyright (c) 2014 Universität Heidelberg. All rights reserved.
//

#import "VIImageOverlayRenderer.h"


@interface VIImageOverlayRenderer ()


@end


@implementation VIImageOverlayRenderer

- (id)initWithOverlay:(id<VIImageOverlay>)overlay {
    if (self = [super initWithOverlay:overlay]) {
        self.opacity = 1;
    }
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    CGRect imageRect = [self rectForMapRect:self.overlay.boundingMapRect];
    CGRect tileRect = [self rectForMapRect:mapRect];

    // only draw a tile of the image
    CGContextAddRect(context, tileRect);
    CGContextClip(context);
    
    // set opacity
    CGContextSetAlpha(context, self.opacity);

    // draw image
    CGContextRotateCTM(context, self.overlay.overlayAngle);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -imageRect.size.height);
    CGContextDrawImage(context, imageRect, self.overlay.overlayImage.CGImage);
    
}

@end
