//
//  UIView+VICategory.m
//  VIFramework
//
//  Created by Nils Fischer on 10.07.11.
//  Copyright 2011 viWiD. All rights reserved.
//

#import "UIView+VICategory.h"


@implementation UIView (VICategory)

- (UIImage *)imageRepresentation {
    return [self imageRepresentationInRect:self.bounds];
}

- (UIImage *)imageRepresentationInRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.);
    [self drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

// still needed??
+ (UIView *)viewInNibNamed:(NSString *)aNibName {
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:aNibName owner:nil options:nil];
    for (id anObject in nibObjects) {
        if ([anObject isKindOfClass:[self class]]) {
            return anObject;
        }
    }
    return nil;
}
+ (UIView *)viewInNibNamed:(NSString *)aNibName withTag:(int)aTag {
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:aNibName owner:nil options:nil];
    for (id anObject in nibObjects) {
        if ([anObject isKindOfClass:[self class]]&&[(UIView *)anObject tag]==aTag) {
            return anObject;
        }
    }
    return nil;
}

@end

@implementation UIView_ScrollviewHittestOverlay

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *child = [super hitTest:point withEvent:event];
    if (child==self) return self.scrollView;
    return child;
}

@end