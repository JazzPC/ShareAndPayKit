//
//  ShareView.h
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/21.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ShareViewDelegate <NSObject>

@required
- (void)shareViewPlatformBtnClickWithTag:(NSInteger)platformName shareTitle:(NSString *)title shareUrl:(NSString *)url shareDesc:(NSString *)desc shareImage:(UIImage *)image respondVC:(UIViewController *)shareVC;

@end

@interface ShareView : UIView
@property (nonatomic, weak) id<ShareViewDelegate>delegate;
/** 分享的地址 */
@property (nonatomic, copy) NSString *shareUrl;
/** 分享的标题 */
@property (nonatomic, copy) NSString *shareTitle;
/** 分享的描述 */
@property (nonatomic, copy) NSString *shareDesc;
/** 分享的图片 */
@property (nonatomic, strong) UIImage *shareImage;
/** 响应的vc */
@property (nonatomic, strong) UIViewController *respVC;

- (void)show;
- (void)hidden;

@end
