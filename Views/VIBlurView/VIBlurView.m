//
//  VIBlurView.m
//  21
//
//  Created by Nils Fischer on 08.11.13.
//
//

#import "VIBlurView.h"
#import "UIImage+ImageEffects.h"
#import "UIView+VICategory.h"

@implementation VIBlurView

- (void)blur {
    UIImage *blurredImage = self.image;

    if (self.backgroundView) {
        blurredImage = [self.backgroundView imageRepresentationInRect:[self convertRect:self.bounds toView:self.backgroundView]];
    }

    blurredImage = [blurredImage applyDarkEffect];
    self.image = blurredImage;
}

- (void)blurAsynchronouslyWithCompletion:(void (^)(void))completionBlock {

    UIImage __block *blurredImage = self.image;

    if (self.backgroundView) {
        blurredImage = [self.backgroundView imageRepresentationInRect:[self convertRect:self.bounds toView:self.backgroundView]];
    }

    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];

    VIBlurView * __weak weakSelf = self;
    [backgroundQueue addOperationWithBlock:^{

        blurredImage = [blurredImage applyDarkEffect];

        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.image = blurredImage;
            if (completionBlock) completionBlock();
        });

    }];

}

@end
