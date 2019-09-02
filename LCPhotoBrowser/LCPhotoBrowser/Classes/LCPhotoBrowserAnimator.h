//
//  LCPhotoBrowserAnimator.h
//  LCPhotoBrowser
//
//  Created by 陈连辰 on 2019/7/10.
//  Copyright © 2019 陈连辰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCPhotoBrowserAnimatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LCPhotoBrowserAnimator : NSObject<UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) id<LCPhotoBrowserAnimatorPresentDelegate> animationPresentDelegate;

@property (nonatomic, weak) id<LCPhotoBrowserAnimatorDismissDelegate> animationDismissDelegate;

/**当前所要查看的图片*/
@property (nonatomic, assign) NSInteger index;
@end

NS_ASSUME_NONNULL_END
