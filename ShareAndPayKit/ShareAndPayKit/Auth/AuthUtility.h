//
//  AuthUtility.h
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/21.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^LoginBlock)(NSDictionary *infoDic);
@interface AuthUtility : NSObject
+ (instancetype)shareInstance;

/**
 处理回调的url

 @param url 回调的url
 @return 返回处理结果
 */
+ (BOOL)handleOpenUrl:(NSURL *)url;

/**
 新浪微博登录点击事件
 */
- (void)sinaLoginPressed;

/**
 QQ登录点击事件
 */
- (void)qqLoginPressed;

/**
 微信登录点击事件
 */
- (void)wechatLoginPressed;

/**
 微信支付点击事件

 @param payData 服务端传回的订单数据
 */
- (void)wechatPayPressed:(NSDictionary *)payData;

/**
 支付宝点击事件

 @param orderString 服务端返回的订单签名
 */
- (void)alipayPressed:(NSString *)orderString;

/**
 登录结果的回调
 */
@property (nonatomic, copy) LoginBlock loginBlock;
@end
