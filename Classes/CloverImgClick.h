//
//  CloverImgClick.h
//  CloverImgClick
//
//  Created by bita on 16/4/25.
//  Copyright © 2016年 Clover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloverImgClick : UIImageView
/**
 *  展示图片到window上
 *
 *  @param defaultImageView 图片控件
 *  @param originalImage    原始图片
 */
- (void)showImageView:(UIView *)view originalImage:(UIImage *)originalImage;
@end
