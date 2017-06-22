//
//  ShareUtility.m
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/21.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#import "ShareUtility.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "ShareView.h"
#import "SPKitEnum.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "common.h"

static ShareUtility *shareInstance = nil;

@interface ShareUtility ()<ShareViewDelegate>
@property (nonatomic, strong) ShareView *shareView;
@end

@implementation ShareUtility
+ (void)shareSetUp {
    [WXApi registerApp:WX_APPID];
    [WeiboSDK registerApp:Sina_APPID];
    [WeiboSDK enableDebugMode:YES];
   id authObj = [[TencentOAuth alloc] initWithAppId:QQ_APPID andDelegate:nil];
    NSLog(@"%@",authObj);
}

+ (void)shareWithUrl:(NSString *)url title:(NSString *)title desc:(NSString *)desc icon:(UIImage *)icon respVC:(UIViewController *)controller {
    if (shareInstance == nil) {
        shareInstance = [[ShareUtility alloc] init];
        shareInstance.shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 150, kScreenWidth, 150)];
        shareInstance.shareView.delegate = shareInstance;
    }
    shareInstance.shareView.shareUrl = url;
    shareInstance.shareView.shareTitle = title;
    shareInstance.shareView.shareDesc = desc;
    shareInstance.shareView.shareImage = icon;
    shareInstance.shareView.respVC = controller;
    [shareInstance.shareView show];
}

#pragma mark - ShareViewDelegate
- (void)shareViewPlatformBtnClickWithTag:(NSInteger)platformName shareTitle:(NSString *)title shareUrl:(NSString *)url shareDesc:(NSString *)desc shareImage:(UIImage *)image respondVC:(UIViewController *)shareVC {
    [shareInstance.shareView hidden];
    switch (platformName) {
        case WXSession:
        case WXTimeLine:
        {
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = title;
            message.description = desc;
            [message setThumbImage:image];
            
            WXWebpageObject *webpageObject = [WXWebpageObject object];
            webpageObject.webpageUrl = url;
            message.mediaObject = webpageObject;
            
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = platformName == WXSession? WXSceneSession:WXSceneTimeline;
            [WXApi sendReq:req];
        }
            break;
        case QQ:
        {
            QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:title description:desc previewImageData:UIImagePNGRepresentation(image)];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
            //将内容分享到qq
            QQApiSendResultCode sent = [QQApiInterface sendReq:req];
            [self handleSendResult:sent];

        }
            break;
        case Sina:
        {
            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
                //TODO: 设置授权回调页面 必须保证和在微博开放平台应用管理界面配置的“授权回调页”地址一致，如未进行配置则默认为`http://`
            authRequest.redirectURI = WB_REDIRECTURI;
            authRequest.scope = @"all";
            
            WBMessageObject *message = [WBMessageObject message];
            message.text = [NSString stringWithFormat:@"%@  %@  ☞%@",title,desc,url];
            WBImageObject *imageObj = [WBImageObject object];
            imageObj.imageData = UIImagePNGRepresentation(image);
            message.imageObject = imageObj;
            
            WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
            [WeiboSDK sendRequest:request];
        }
            break;
        default:
            break;
    }
}

- (void)handleSendResult:(QQApiSendResultCode)code {
    switch (code) {
        case EQQAPISENDSUCESS:
        {
            NSLog(@"发送成功");
        }
            break;
        case EQQAPIQQNOTINSTALLED:
        {
            NSLog(@"未安装QQ");
        }
            break;
        case EQQAPIQQNOTSUPPORTAPI:
        {
            NSLog(@"API不支持");
        }
            break;
        case EQQAPIMESSAGETYPEINVALID:
        {
            NSLog(@"消息类型无效");
        }
            break;
        case EQQAPIAPPNOTREGISTED:
        {
            NSLog(@"APP未注册");
        }
            break;
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        {
            
            NSLog(@"发送参数错误");
            break;
        }
        case EQQAPISENDFAILD:
        {
            
            NSLog(@"发送失败");
            
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:
        {
            
            NSLog(@"当前QQ版本太低，需要更新");
            break;
        }
        default:
            break;
    }
}


@end
