//
//  ViewController.m
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/20.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#import "ViewController.h"
#import "ShareUtility.h"
#import "AuthUtility.h"
@interface ViewController ()
- (IBAction)shareButtonPressed:(UIButton *)sender;
- (IBAction)qqLogin:(UIButton *)sender;
- (IBAction)wechatLogin:(UIButton *)sender;
- (IBAction)sinaLogin:(UIButton *)sender;
- (IBAction)wechatPay:(UIButton *)sender;
- (IBAction)aliPay:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareButtonPressed:(UIButton *)sender {
    
    [ShareUtility shareWithUrl:@"http://www.baidu.com" title:@"你好" desc:@"测试分享" icon:[UIImage imageNamed:@"icon"] respVC:self];
}

- (IBAction)qqLogin:(UIButton *)sender {
    [[AuthUtility shareInstance] qqLoginPressed];
    [AuthUtility shareInstance].loginBlock = ^(NSDictionary *infoDic) {
        //TODO:处理登录逻辑
        if (infoDic != nil) {
            
        }else {
            NSLog(@"登录失败");
        }
    };
}

- (IBAction)wechatLogin:(UIButton *)sender {
    [[AuthUtility shareInstance] wechatLoginPressed];
    [AuthUtility shareInstance].loginBlock = ^(NSDictionary *infoDic) {
        //TODO:处理登录逻辑
        if (infoDic != nil) {
            
        }else {
            NSLog(@"登录失败");
        }
    };
}

- (IBAction)sinaLogin:(UIButton *)sender {
    [[AuthUtility shareInstance] sinaLoginPressed];
    [AuthUtility shareInstance].loginBlock = ^(NSDictionary *infoDic) {
        //TODO:处理登录逻辑
        if (infoDic != nil) {
            
        }else {
            NSLog(@"登录失败");
        }
    };
}

- (IBAction)wechatPay:(UIButton *)sender {
    //FIXME:方法参数需要服务端返回，这里暂时为nil
    [[AuthUtility shareInstance] wechatPayPressed:nil];
}

- (IBAction)aliPay:(UIButton *)sender {
    //FIXME:方法参数需要服务端返回，这里暂时为nil
    [[AuthUtility shareInstance] alipayPressed:nil];
    
}
@end
