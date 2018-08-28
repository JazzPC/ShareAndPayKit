//
//  AuthUtility.m
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/21.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#import "AuthUtility.h"
#import "common.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import <AlipaySDK/AlipaySDK.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//#import <TencentOpenAPI/TencentApiInterface.h>


static AuthUtility *shareInstance = nil;

@interface AuthUtility ()<TencentLoginDelegate,WXApiDelegate,WeiboSDKDelegate>
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@end

@implementation AuthUtility

+ (instancetype)shareInstance {
    if (shareInstance == nil) {
        shareInstance = [[AuthUtility alloc] init];
    }
    return shareInstance;
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:QQ_APPID].location != NSNotFound) {
        [TencentOAuth HandleOpenURL:url];
    }else if ([urlString rangeOfString:WX_APPID].location != NSNotFound) {
        [WXApi handleOpenURL:url delegate:[AuthUtility shareInstance]];
    }else if ([urlString rangeOfString:Sina_APPID].location != NSNotFound) {
        [WeiboSDK handleOpenURL:url delegate:[AuthUtility shareInstance]];
    }else if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
        //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
            }];
    }else if ([url.host isEqualToString:@"platformapi"]) {
        // 授权跳转支付宝钱包进行支付，处理支付结果
        //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }
    return YES;
}

#pragma mark - 新浪微博登录
- (void)sinaLoginPressed {
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    //TODO: 必须保证和在微博开放平台应用管理界面配置的“授权回调页”地址一致，如未进行配置则默认为`http://`
    request.redirectURI = WB_REDIRECTURI;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
        if (!authResponse.userID) return;
        if (self.loginBlock) {
            self.loginBlock(@{@"Type":@"weibo", @"TokenKey":authResponse.accessToken, @"AccessToken":authResponse.accessToken, @"Uid":authResponse.userID, @"Uname":@""});
        }
        
    }
}


#pragma mark - QQ登录
- (void)qqLoginPressed {
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            nil];
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQ_APPID andDelegate:(id<TencentSessionDelegate>)self];
    
    [_tencentOAuth authorize:permissions];
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (self.loginBlock) {
        self.loginBlock(nil);
    }
}

- (void)tencentDidLogin {
    if (_tencentOAuth.accessToken) {
        //登录操作
        if (self.loginBlock) {
            self.loginBlock(@{@"Type":@"QQ", @"TokenKey":_tencentOAuth.accessToken, @"AccessToken":_tencentOAuth.accessToken, @"Uid":_tencentOAuth.openId, @"Uname":@""});
        }
    }
}

- (void)tencentDidNotNetWork {
    if (self.loginBlock) {
        self.loginBlock(nil);
    }
}

#pragma mark - 微信登录
- (void)wechatLoginPressed {
    SendAuthReq *req = [SendAuthReq new];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"app_wechat_login" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}
#pragma mark - 微信支付

/**
 调起微信支付

 @param payData 服务端返回的订单信息
 */
- (void)wechatPayPressed:(NSDictionary *)payData {
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = payData[@""]; /** 商家向财付通申请的商家id */
    request.prepayId= payData[@""];   /** 预支付订单 */
    request.package = payData[@""];   /** 商家根据财付通文档填写的数据和签名 */
    request.nonceStr= payData[@""];   /** 随机串，防重发 */
    request.timeStamp= (UInt32)[payData[@""] intValue];/** 时间戳，防重发 */
    request.sign= payData[@""];/** 商家根据微信开放平台文档对数据做的签名 */
    
    [WXApi sendReq:request];
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp 具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode != 0) {
            if (resp.errCode == -4) {
                NSLog(@"用户拒绝授权");
            }else if (resp.errCode == -2) {
                NSLog(@"用户取消");
            }
            return;
        }
        //获取第一步的code后,请求以下链接获取access_token：
        SendAuthResp *authResp = (SendAuthResp *)resp;
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WX_APPID,WX_APPSECRET,authResp.code]];
        NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                /* "access_token":"ACCESS_TOKEN",
                 "expires_in":7200,
                 "refresh_token":"REFRESH_TOKEN",
                 "openid":"OPENID",
                 "scope":"SCOPE",
                 "unionid":"o6_bmasdasdsad6_2sgVt7hMZOPfL"
                 */
                NSLog(@"%@",responseObject);
                if (self.loginBlock) {
                    self.loginBlock(@{@"Type":@"wechat", @"TokenKey":responseObject[@"access_token"], @"AccessToken":responseObject[@"access_token"], @"Uid":responseObject[@"openid"], @"Uname":@""});
                }
            }else {
                if (self.loginBlock) {
                    self.loginBlock(nil);
                }
            }
        }];
        //启动任务
        [task resume];
        
    }else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
            }
                break;
            case WXErrCodeCommon:
            {
                NSLog(@"普通错误类型");
            }
                break;
            case WXErrCodeUserCancel:
            {
                NSLog(@"用户点击取消并返回");
            }
                break;
            case WXErrCodeSentFail:
            {
                NSLog(@"发送失败");
            }
                break;
            case WXErrCodeAuthDeny:
            {
                NSLog(@"授权失败");
            }
                break;
            case WXErrCodeUnsupport:
            {
                NSLog(@"微信不支持");
            }
                break;
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}

#pragma mark - 支付宝支付

/**
 向AlipaySDK发送支付消息

 @param orderString 服务端返回的订单信息(订单信息需要在服务端进行组装后返回)
 */
- (void)alipayPressed:(NSString *)orderString {
    NSLog(@"%@",[[AlipaySDK defaultService] currentVersion]);
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:ALIPAY_SCHEME callback:^(NSDictionary *resultDic) {
        // 处理返回结果
        NSString* resultCode = resultDic[@"resultCode"];
        //code = 9000 支付成功
        //建议操作: 根据resultCode做处理
        // returnUrl 代表 第三方App需要跳转的成功页URL
        NSString* returnUrl = resultDic[@"returnUrl"];
        NSLog(@"%@",returnUrl);
        //建议操作: 打开returnUrl
        
        switch ([resultDic[@"resultStatus"] intValue]) {
            case 9000:
            {
                NSLog(@"支付成功!");
            }
                break;
            case 8000://订单处理中
            case 4000://支付失败
            case 5000://重复请求
            {
                NSLog(@"支付失败!");
            }
                break;
            case 6001:
            {
                NSLog(@"支付取消!");
            }
                break;
            case 6002:
            {
                NSLog(@"网络连接出错!");
            }
                break;
            case 6004:
            {
                NSLog(@"支付结果未知!");
            }
                break;
                
            default:
                break;
        }
    }];
}


@end
