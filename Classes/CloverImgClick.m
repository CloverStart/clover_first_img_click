//
//  CloverImgClick.m
//  CloverImgClick
//
//  Created by bita on 16/4/25.
//  Copyright © 2016年 Clover. All rights reserved.
//
// 屏幕尺寸
#define ScreenWidth       [[UIScreen mainScreen]bounds].size.width
#define ScreenHeight      [[UIScreen mainScreen]bounds].size.height


#import "CloverImgClick.h"
static float kDuration = 0.5;
@interface CloverImgClick()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    //---用于按屏幕比例缩放图像
    UIView* container_View;
    //---利用 Scrollview 的缩放功能来缩放图像
    UIScrollView *container_ScrollView;
    //---保存放大前原始图片在 window 上的坐标和大小
    CGRect originImageRect;
    //---设置动画时间
    CGFloat duration;
    //---保存缩放的图像
    UIImageView *snapShotView;
    //---关闭按钮
    UIButton *hideImgBtn;
}
@end

@implementation CloverImgClick

//---StoryBoard 中初始化时
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //---为 UIImageview 添加点击手势
                UITapGestureRecognizer *tap_Gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
                [tap_Gesture setNumberOfTapsRequired:1];
                self.userInteractionEnabled = YES;
                [self addGestureRecognizer:tap_Gesture];
        //---初始化时间
        duration = kDuration;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //---为 UIImageview 添加点击手势
                UITapGestureRecognizer *tap_Gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
                [tap_Gesture setNumberOfTapsRequired:1];
                self.userInteractionEnabled = YES;
                [self addGestureRecognizer:tap_Gesture];
        //---初始化时间
        duration = kDuration;
    }
    return self;
}

- (void)tapImage:(UIGestureRecognizer*)sender
{
    UIImageView *imageView = (UIImageView *)sender.view;
    [self showImageView:sender.view originalImage:imageView.image];
}

- (void)showImageView:(UIView *)view originalImage:(UIImage *)originalImage
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    //---将 imageview 的坐标转换到屏幕上的坐标位置，
    originImageRect = [view convertRect:view.bounds toView:window];;
    //---添加容器 container_ScrollView
    container_ScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    container_ScrollView.delegate=self;
    //---设置最大伸缩比例
    container_ScrollView.maximumZoomScale=3.0;
    container_ScrollView.showsVerticalScrollIndicator = NO;
    container_ScrollView.showsHorizontalScrollIndicator = NO;
    //---设置最小伸缩比例
    //container_ScrollView.minimumZoomScale=0.5;
    
    //---添加容器 container_View，用于缩放
    //---若是直接缩放图像，若是图片的大小比例不是屏幕的大小，缩放的时候会有位移偏差
    container_View = [UIView new];
    container_View.frame = container_ScrollView.frame;
    container_View.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    //---加载原图
    snapShotView = [[UIImageView alloc]init];
    snapShotView.image = originalImage;
    snapShotView.frame = originImageRect;
    
    //---加载到屏幕上
    [container_View addSubview:snapShotView];
    [container_ScrollView addSubview:container_View];
    [window addSubview:container_ScrollView];
    
    //---添加全局手势 点击缩小回原位
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [container_ScrollView addGestureRecognizer:tap];
    //    ---添加按钮 点击缩小回复原位 未使用
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    button.frame = CGRectMake(10, 20, 60, 30);
    //    button.backgroundColor  = [UIColor cyanColor];
    //    [button setTitle:@"关闭" forState:UIControlStateNormal];
    //    [button addTarget:self action:@selector(hideImage:) forControlEvents:UIControlEventTouchUpInside];
    //    hideImgBtn = button;
    //    [window addSubview:hideImgBtn];
    //---设置图片开始是透明的
    self.alpha = 0;
    container_ScrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    //---移动到屏幕中央
    UIImage *image = originalImage;
    CGFloat rate = ScreenWidth / image.size.width;
    CGRect finalRect = CGRectMake(0,
                                  (ScreenHeight - image.size.height * rate )/2,
                                  ScreenWidth,
                                  image.size.height * rate );
    //---动画显示
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        snapShotView.frame = finalRect;
        container_ScrollView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        
    }
                     completion:^(BOOL finished)
     {
         //---隐藏状态栏
         [UIApplication.sharedApplication setStatusBarHidden:true withAnimation:UIStatusBarAnimationSlide];
     }];
    
}

- (void)hideImage:(id)sender
{
    [UIApplication.sharedApplication setStatusBarHidden:false withAnimation:UIStatusBarAnimationNone];
    
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //---缩放到原始大小时，必须同时缩放到原始的倍率，否则放大的情况位置偏移
        container_ScrollView.zoomScale = 1.0f;
        snapShotView.frame = originImageRect;
        container_ScrollView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [hideImgBtn removeFromSuperview];
    } completion:^(BOOL finished) {
        self.alpha = 1;
        [container_ScrollView removeFromSuperview];
    }];
}

#pragma mark - UIScrollView Delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //---缩放容器container_View
    return container_View;
}


@end
