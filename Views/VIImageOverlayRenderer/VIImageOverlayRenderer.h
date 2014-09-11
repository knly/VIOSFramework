//
//  VIImageOverlayRenderer.h
//  uni-hd
//
//  Created by Andreas Schachner on 03.09.14.
//  Copyright (c) 2014 Universität Heidelberg. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol VIImageOverlay <MKOverlay>

- (UIImage *)overlayImage;
- (CGFloat)overlayAngle;

@end


@interface VIImageOverlayRenderer : MKOverlayRenderer

@property (nonatomic, readonly) id <VIImageOverlay> overlay;

@property (nonatomic) CGFloat opacity;

- (id)initWithOverlay:(id<VIImageOverlay>)overlay;

@end
