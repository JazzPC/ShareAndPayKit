//
//  common.h
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/21.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#ifndef common_h
#define common_h


#define WX_APPID     @"wxd930ea5d5a258f4f"
#define WX_APPSECRET @"0a8410944ae06a1a3cb91bb502c54080"
#define QQ_APPID     @"222222"
#define Sina_APPID   @"2045436852"
#define WB_REDIRECTURI  @"http://www.weibo.com"

#define ALIPAY_SCHEME @"alisdkdemo"
#define ALIPAY_APPID @"2015052600090779"
//支付宝私钥 商户实际支付过程中参数需要放置在服务端，且整个签名过程必须在服务端进行
#define ALIPAY_PRIVATE_KEY @""
//屏幕宽高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#endif /* common_h */
