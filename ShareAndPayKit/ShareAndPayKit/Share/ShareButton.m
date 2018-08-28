//
//  ShareButton.m
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/21.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#import "ShareButton.h"

@implementation ShareButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageW = CGRectGetWidth(contentRect);
    CGFloat imageH = imageW;
    return CGRectMake(0, 0, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleY = contentRect.size.height * 0.8 + 5;
    CGFloat titleH = contentRect.size.height * 0.2;
    CGFloat titleW = contentRect.size.width;
    return CGRectMake(0, titleY, titleW, titleH);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
