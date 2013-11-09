//
//  VISegmentedContainerViewController.m
//  21
//
//  Created by Nils Fischer on 02.11.13.
//
//

#import "VISegmentedContainerViewController.h"

@interface VISegmentedContainerViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) UIViewController *currentViewController;

- (UIViewController *)contentViewControllerForIndex:(NSUInteger)index;
- (void)cycleFromViewController:(UIViewController*)fromVC toViewController:(UIViewController*)toVC;

@end

@implementation VISegmentedContainerViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.segmentedControl.selectedSegmentIndex = 0;
    [self segmentedControlDidChangeValue:self.segmentedControl];
}

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex!=UISegmentedControlNoSegment) {
        [self cycleFromViewController:self.currentViewController toViewController:[self contentViewControllerForIndex:sender.selectedSegmentIndex]];
    }
}

- (void)cycleFromViewController:(UIViewController*)fromVC toViewController:(UIViewController*)toVC {

    if (!toVC||toVC==fromVC) return;

    toVC.view.frame = self.contentView.bounds;

    [fromVC willMoveToParentViewController:nil];
    [self addChildViewController:toVC];

    if (!fromVC) {
        [self.contentView addSubview:toVC.view];
        [toVC didMoveToParentViewController:self];
        self.currentViewController = toVC;
        return;
    }

    toVC.view.alpha = 0.;
    [self transitionFromViewController:fromVC toViewController:toVC duration:0.25 options:0 animations:^{
        toVC.view.alpha = 1.;
        fromVC.view.alpha = 0.;
    } completion:^(BOOL finished) {
        [fromVC removeFromParentViewController];
        [toVC didMoveToParentViewController:self];
        self.currentViewController = toVC;
    }];
}

- (UIViewController *)contentViewControllerForIndex:(NSUInteger)index {
    // to override in subclass
    return nil;
}


@end
