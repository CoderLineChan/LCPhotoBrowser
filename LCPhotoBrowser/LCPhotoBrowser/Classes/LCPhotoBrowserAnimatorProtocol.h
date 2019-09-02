//
//  LCPhotoBrowserAnimatorProtocol.h
//  LCPhotoBrowser
//
//  Created by 陈连辰 on 2019/7/10.
//  Copyright © 2019 陈连辰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 图片开始浏览协议
 */
@protocol LCPhotoBrowserAnimatorPresentDelegate <NSObject>
/**
 获取图片浏览前的位置
 
 @param index 图片的下标
 @return 图片相对于window的位置
 */
- (CGRect)startRect:(NSInteger)index;

/**
 获取图片浏览中的位置
 
 @param index 图片的下标
 @return 图片在图片查看控制器中位置
 */
- (CGRect)endRect:(NSInteger)index;

/**
 获取当前要浏览的图片
 
 @param index 图片的下标
 @return 当前要浏览的图片
 */
- (UIImageView *)locImageView:(NSInteger)index;

@end

/**
 图片结束浏览协议
 */
@protocol LCPhotoBrowserAnimatorDismissDelegate <NSObject>

/**
 获取当前浏览的图片的下标
 
 @return 当前浏览图片的下标
 */
- (NSInteger)indexForDismissView;

/**
 获取当前浏览的图片
 
 @return 当前浏览的图片
 */
- (UIImageView *)imageViewForDismissView;

@end


NS_ASSUME_NONNULL_END
