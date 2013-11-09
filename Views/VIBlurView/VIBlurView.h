//
//  VIBlurView.h
//  21
//
//  Created by Nils Fischer on 08.11.13.
//
//

#import <UIKit/UIKit.h>

@interface VIBlurView : UIImageView

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

- (void)blur;
- (void)blurAsynchronouslyWithCompletion:(void (^)(void))completionBlock;

@end
