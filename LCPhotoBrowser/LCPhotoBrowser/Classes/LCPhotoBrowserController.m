//
//  LCPhotoBrowserController.m
//  LCPhotoBrowser
//
//  Created by 陈连辰 on 2019/7/10.
//  Copyright © 2019 陈连辰. All rights reserved.
//

#import "LCPhotoBrowserController.h"
#import "LCPhotoBrowserAnimator.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDImageCache.h>

#define kRoot_VC UIApplication.sharedApplication.keyWindow.rootViewController
#define kScreenW UIScreen.mainScreen.bounds.size.width
#define kScreenH UIScreen.mainScreen.bounds.size.height
/// 消除警告
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface LCPhotoBrowserController ()<LCPhotoBrowserAnimatorPresentDelegate, LCPhotoBrowserAnimatorDismissDelegate, UIScrollViewDelegate>

/** 小图 */
@property(nonatomic, strong)UIImageView *smallImageView;
/** 原图 */
@property(nonatomic, strong)UIImageView *imageView;
/** 原图地址 */
@property(nonatomic, strong)NSString *url;
/** 传进来的图片 */
@property(nonatomic, strong)UIImage *image;
/** 放大前的frame */
@property(nonatomic, assign)CGRect smallFrame;
/** 放大后的frame */
@property(nonatomic, assign)CGRect targetFrame;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
/** scrollView */
@property(nonatomic, strong)UIScrollView *scrollView;
/** 是否缩放 */
@property(nonatomic, assign)BOOL isZoom;
/** 转场动画 */
@property(nonatomic, strong)LCPhotoBrowserAnimator *animator;
@end

@implementation LCPhotoBrowserController


#pragma mark - 快捷方法

+ (void)showPhotoFromImageView:(UIImageView *)imageView imageUrl:(NSString *)imageUrl {
    LCPhotoBrowserController *photoVC = [[LCPhotoBrowserController alloc] initWithSmallImageView:imageView imageUrl:imageUrl];
    photoVC.modalPresentationStyle = UIModalPresentationCustom;
    photoVC.transitioningDelegate = photoVC.animator;
    photoVC.animator.animationPresentDelegate = photoVC;
    photoVC.animator.index = 0;
    photoVC.animator.animationDismissDelegate = photoVC;
    [kRoot_VC presentViewController:photoVC animated:YES completion:nil];
}


#pragma mark - 初始化
- (instancetype)initWithSmallImageView:(UIImageView *)smallImageView imageUrl:(NSString *)imageUrl {
    self = [super init];
    if (self) {
        self.url = imageUrl;
        UIImage *image = smallImageView.image;
        /// 把原来的位置转换到window中的位置
        CGRect conver = [smallImageView.superview convertRect:smallImageView.frame toView:nil];
        self.smallFrame = conver;
        self.image = image;
        self.smallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        self.smallImageView.image = self.image;
        self.targetFrame = [self calculateTargetFrameWithImage:image];
        
    }
    return self;
}


#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    [self addGesture];
    
    [self.view addSubview:self.indicator];
    
    [self setupScrollView];
    
    /// 加载图片
    __weak typeof(self) weakSelf = self;
    [self.indicator startAnimating];
    [self loadImageWithUrlStr:self.url complete:^(BOOL isSucceed, UIImage *image, NSError *error) {
        [weakSelf.indicator stopAnimating];
        if (!isSucceed) {
            NSLog(@"加载图片失败error:%@", error.domain);
            return ;
        }
        weakSelf.imageView.image = image;
        weakSelf.view.backgroundColor = [UIColor blackColor];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
    //        [self prefersStatusBarHidden];
    //        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    //    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView.frame = self.targetFrame;
    if (!self.url) {
        self.imageView.image = self.image;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.view.backgroundColor = [UIColor blackColor];
    }
    self.scrollView.contentSize = self.imageView.image.size;
    [self scrollViewDidZoom:self.scrollView];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

#pragma mark - 初始化
- (void)setupScrollView {
    self.view.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        SuppressPerformSelectorLeakWarning(self.automaticallyAdjustsScrollViewInsets = NO);
        
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    _scrollView.delegate = self;
    [_scrollView addSubview:self.imageView];
    _scrollView.maximumZoomScale = 3;
    _scrollView.minimumZoomScale = 1;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
}
/// 添加手势
- (void)addGesture {
    /// 单击
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTapGesture];
    /// 双击
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}
- (void)handleSingleTap:(UIGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)handleDoubleTap:(UIGestureRecognizer *)gesture {
    self.isZoom = !self.isZoom;
    [self.scrollView setZoomScale:self.isZoom ? 2.5 : 1 animated:YES];
    
}
#pragma mark - 缩放代理
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateFrame];
}
///更新位置
- (void)updateFrame {
    CGRect frame = self.imageView.frame;
    frame.origin.y = (self.scrollView.frame.size.height - self.imageView.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.imageView.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.imageView.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.imageView.frame.size.width) * 0.5 : 0;
    self.imageView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
}
#pragma mark - 动画的协议
- (UIImageView *)locImageView:(NSInteger)index {
    return self.smallImageView;
}

- (CGRect)startRect:(NSInteger)index {
    return self.smallFrame;
}
- (CGRect)endRect:(NSInteger)index {
    return self.targetFrame;
}
- (NSInteger)indexForDismissView {
    return 0;
}
- (UIImageView *)imageViewForDismissView {
    return self.smallImageView;
}
#pragma mark - 懒加载
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
    }
    return _imageView;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(kScreenW * 0.5 - 10,kScreenH * 0.5 - 10,20,20)];
    }
    return _indicator;
}
- (LCPhotoBrowserAnimator *)animator {
    if (!_animator) {
        _animator = [[LCPhotoBrowserAnimator alloc] init];
    }
    return _animator;
}
#pragma mark - 位置转换, 计算位置
/// 转换目标位置
- (CGRect)calculateTargetFrameWithImage:(UIImage *)image {
    CGRect frame = CGRectZero;
    /// 计算放大后的frame
    if (image.size.height >= image.size.width) {
        frame = [self verticalExtendWithSize:image.size];
    }else {
        if ((image.size.width / image.size.height) < (kScreenW / kScreenH)) {
            frame = [self verticalExtendWithSize:image.size];
        }else {
            frame = [self horizontalExtendWithSize:image.size];
        }
    }
    return frame;
}
/// 纵向放大
- (CGRect)verticalExtendWithSize:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.size.width = kScreenH / size.height * size.width;
    frame.size.height = kScreenH;
    frame.origin.y = 0;
    frame.origin.x = (kScreenW - frame.size.width) * 0.5;
    return frame;
}
/// 横向放大
- (CGRect)horizontalExtendWithSize:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.size.width = kScreenW;
    frame.size.height = kScreenW / size.width * size.height;
    frame.origin.y = (kScreenH - frame.size.height) * 0.5;
    frame.origin.x = 0;
    return frame;
}
#pragma mark - 加载图片
/// 加载图片操作
- (void)loadImageWithUrlStr:(NSString *)urlStr complete:(void(^)(BOOL isSucceed, UIImage *image, NSError *error))complete {
    NSURL *URL = [NSURL URLWithString:urlStr];
    if (!URL || urlStr.length <= 0) {
        NSError *error = [NSError errorWithDomain:@"Picture address is invalid" code:1000 userInfo:nil];
        complete ? complete(NO, nil, error) : nil;
        return;
    }
    /// 如果已经缓存过的图片, 直接取出来显示
    UIImage *image = [SDImageCache.sharedImageCache imageFromCacheForKey:urlStr];
    if (image) {
        complete ? complete(YES, image, nil) : nil;
    }else {
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:urlStr] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (error) {
                complete ? complete(NO, nil, error) : nil;
                return ;
            }
            if (image) {
                complete ? complete(YES, image, nil) : nil;
                [SDImageCache.sharedImageCache storeImage:image forKey:urlStr completion:nil];
            }
        }];
    }
}

@end
