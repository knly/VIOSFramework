//
//  UIView+VICategory.h
//  VIFramework
//
//  Created by Nils Fischer on 10.07.11.
//  Copyright 2011 viWiD. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (VICategory)

- (UIImage *)imageRepresentation;
- (UIImage *)imageRepresentationInRect:(CGRect)rect;

+ (UIView *)viewInNibNamed:(NSString *)aNibName;
+ (UIView *)viewInNibNamed:(NSString *)aNibName withTag:(int)aTag;

@end

@interface UIView_ScrollviewHittestOverlay : UIView

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end