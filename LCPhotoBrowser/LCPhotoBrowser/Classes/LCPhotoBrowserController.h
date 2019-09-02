//
//  LCPhotoBrowserController.h
//  LCPhotoBrowser
//
//  Created by 陈连辰 on 2019/7/10.
//  Copyright © 2019 陈连辰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCPhotoBrowserController : UIViewController
#pragma mark - 快捷显示大图
/**
 显示图片
 
 @param imageView 图片的imageView(小图)
 @param imageUrl 图片地址(原图)
 */
+ (void)showPhotoFromImageView:(UIImageView *)imageView imageUrl:(NSString *)imageUrl;


#pragma mark - 控制器初始化

/**
 初始化
 
 @param smallImageView 图片的imageView(小图)
 @param imageUrl 图片地址
 */
- (instancetype)initWithSmallImageView:(UIImageView *)smallImageView imageUrl:(NSString *)imageUrl;
@end

NS_ASSUME_NONNULL_END
