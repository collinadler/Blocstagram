//
//  BLCMediaFullScreenAnimator.m
//  Blocstagram
//
//  Created by Collin Adler on 11/9/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCMediaFullScreenAnimator.h"
#import "BLCMediaFullScreenViewController.h"

@implementation BLCMediaFullScreenAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    //an NSTimeInterval can be any double number. It's always specified in seconds
    return 0.2;
}

/* 
 The method is passed a transition context object called transitionContext. This object gives us 3 crucial pieces of information:
    1. The view controller the user is leaving (UITransitionContextFromViewControllerKey)
    2. The view controller the user is going to (UITransitionContextToViewControllerKey)
    3. A container view, which contains the views of both view controllers during the animation
We calculate (and specify) the starting and ending frame for the view controller that's moving.
We animate the view controller using the frames we calculated.
Finally, we inform the transition context when the animation is completed. 
*/
- (void) animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) { //will occur after the user taps an image
        BLCMediaFullScreenViewController *fullScreenVC = (BLCMediaFullScreenViewController *)toViewController;
        
        fromViewController.view.userInteractionEnabled = NO;
        
        //A container view contains the views of both view controllers during the animation
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        //converts a view's frame or bounds from one view's coordinate system into the receiver's
        CGRect startFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
        //we want the full screen view to use the same position and sizing as the regular view controller, so we just copy its frame
        CGRect endFrame = fromViewController.view.frame;
        
        toViewController.view.frame = startFrame;
        fullScreenVC.imageView.frame = toViewController.view.bounds;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            
            fullScreenVC.view.frame = endFrame;
            [fullScreenVC centerScrollView];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        BLCMediaFullScreenViewController *fullScreenVC = (BLCMediaFullScreenViewController *)fromViewController;
        
        CGRect endFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
        CGRect imageStartFrame = [fullScreenVC.view convertRect:fullScreenVC.imageView.frame fromView:fullScreenVC.scrollView];
        CGRect imageEndFrame = [transitionContext.containerView convertRect:endFrame toView:fullScreenVC.view];
        
        imageEndFrame.origin.y = 0;
        
        [fullScreenVC.view addSubview:fullScreenVC.imageView];
        fullScreenVC.imageView.frame = imageStartFrame;
        fullScreenVC.imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        
        toViewController.view.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fullScreenVC.view.frame = endFrame;
            fullScreenVC.imageView.frame = imageEndFrame;
            
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
