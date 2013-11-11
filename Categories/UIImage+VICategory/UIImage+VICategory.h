//
//  UIImage+VICategory.h
//  21
//
//  Created by Nils Fischer on 11.11.13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (VICategory)

+ (UIImage *)cachedImageNamed:(NSString *)name;
+ (void)emptyCache;

@end
