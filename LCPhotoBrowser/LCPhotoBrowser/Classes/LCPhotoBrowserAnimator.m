//
//  LCPhotoBrowserAnimator.m
//  LCPhotoBrowser
//
//  Created by 陈连辰 on 2019/7/10.
//  Copyright © 2019 陈连辰. All rights reserved.
//

#import "LCPhotoBrowserAnimator.h"
#define kAnimationDuration 0.2

@interface LCPhotoBrowserAnimator ()
@property(nonatomic, assign, getter=isPresented) BOOL presented;
@end
@implementation LCPhotoBrowserAnimator


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.presented = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.presented = NO;
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return kAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    if(self.isPresented){
        [self animationForPresentView:transitionContext];
    } else{
        [self animationForDismissView:transitionContext];
    }
}

//自定义弹出动画
- (void)animationForPresentView:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *presentView = [transitionContext viewForKey:UITransitionContextToViewKey];
    //将执行的View添加到containerView
    [transitionContext.containerView addSubview:presentView];
    
    //获取开始尺寸和结束尺寸
    CGRect startRect = [self.animationPresentDelegate startRect:self.index];
    CGRect endRect = [self.animationPresentDelegate endRect:self.index];
    UIImageView *imageView = [self.animationPresentDelegate locImageView:self.index];
    [transitionContext.containerView insertSubview:imageView belowSubview:transitionContext.containerView.subviews.firstObject];
    imageView.frame = startRect;
    presentView.alpha = 0;
    transitionContext.containerView.backgroundColor = [UIColor blackColor];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        imageView.frame = endRect;
    }completion:^(BOOL finished) {
        presentView.alpha = 1.0;
        transitionContext.containerView.backgroundColor = [UIColor blackColor];
        [transitionContext completeTransition:YES];
    }];
}

//自定义消失动画
- (void)animationForDismissView:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *dismissView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [dismissView removeFromSuperview];
    
    UIImageView *imageView = [self.animationDismissDelegate imageViewForDismissView];
    [transitionContext.containerView addSubview:imageView];
    NSInteger index = [self.animationDismissDelegate indexForDismissView];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        transitionContext.containerView.backgroundColor = [UIColor clearColor];
        imageView.frame = [self.animationPresentDelegate startRect:index];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}
@end
