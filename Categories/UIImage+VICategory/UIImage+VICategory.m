//
//  UIImage+VICategory.m
//  21
//
//  Created by Nils Fischer on 11.11.13.
//
//

#import "UIImage+VICategory.h"

static NSCache *_cache = nil;

@implementation UIImage (VICategory)

+ (UIImage *)cachedImageNamed:(NSString *)name {
    if (!_cache) _cache = [[NSCache alloc] init];

    if (![_cache objectForKey:name]) {
        // TODO: implement caching mechanism
        [_cache setObject:[UIImage imageNamed:name] forKey:name];
    }

    return [_cache objectForKey:name];
}

+ (void)emptyCache {
    [_cache removeAllObjects];
}

@end
