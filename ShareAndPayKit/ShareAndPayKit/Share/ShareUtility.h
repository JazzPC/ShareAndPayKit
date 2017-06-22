//
//  ShareUtility.h
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/21.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShareUtility : NSObject
+ (void)shareSetUp;
///分享方法
+ (void)shareWithUrl:(NSString *)url title:(NSString *)title desc:(NSString *)desc icon:(UIImage *)icon respVC:(UIViewController *)controller;
@end
