//
//  ShareView.m
//  ShareAndPayKit
//
//  Created by PanChuang on 2017/6/21.
//  Copyright © 2017年 JazzPC. All rights reserved.
//

#import "ShareView.h"
#import "SPKitEnum.h"
#import "ShareButton.h"
#import "WXApi.h"
#import "common.h"
#import <TencentOpenAPI/QQApiInterface.h>

@interface ShareView ()
@property (nonatomic, strong) UILabel      *titleLabel;
@property (nonatomic, strong) UIScrollView *shareScrollView;
@property (nonatomic, strong) UIButton     *cancelButton;
@property (nonatomic, strong) UIView       *lineView;
@end

@implementation ShareView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
        [self addSubViews];
    }
    return self;
}

- (void)addSubViews {
    UIView *lineView = [[UIView alloc] init];
    [self addSubview:lineView];
    self.lineView = lineView;
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    UIScrollView *shareScrollView = [[UIScrollView alloc] init];
    [self addSubview:shareScrollView];
    self.shareScrollView = shareScrollView;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:cancelButton];
    self.cancelButton = cancelButton;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.lineView.frame = CGRectMake(0, 1, kScreenWidth, 1);
    self.lineView.backgroundColor = [UIColor lightGrayColor];
    self.titleLabel.frame = CGRectMake(0, 5, kScreenWidth, 20);
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"分享到";
    self.cancelButton.frame = CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40);
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.shareScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.frame.size.width, self.frame.size.height - self.titleLabel.frame.size.height - self.cancelButton.frame.size.height);
    self.shareScrollView.showsVerticalScrollIndicator = NO;
    self.shareScrollView.showsHorizontalScrollIndicator = NO;
    
    [self configSharePlatform];
}

- (void)configSharePlatform {
    NSMutableArray *titleArr = [[self getSharePlatform] objectForKey:@"title"];
    NSMutableArray *imageArr = [[self getSharePlatform] objectForKey:@"image"];
    CGFloat buttonW = 65;
    CGFloat buttonH = 65;
    CGFloat speedW = 25;
    for (int i = 0; i < titleArr.count; i++) {
        ShareButton *btn = [ShareButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(20 + (speedW + buttonW) * i, 10, buttonW, buttonH);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imageArr[i]] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if ([titleArr[i] isEqualToString:@"微信"]) {
            btn.tag = 1001;
        }else if ([titleArr[i] isEqualToString:@"朋友圈"]){
            btn.tag = 1002;
        }else if ([titleArr[i] isEqualToString:@"QQ"]){
            btn.tag = 1003;
        }else{
            btn.tag = 1004;
        }
        if (i == titleArr.count) {
            self.shareScrollView.contentSize = CGSizeMake(btn.frame.origin.x + btn.frame.size.width + 20, 0);
        }
        [self.shareScrollView addSubview:btn];
        
        [btn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (NSDictionary *)getSharePlatform {
    NSMutableArray *titleArray = [NSMutableArray array];
    NSMutableArray *imageArray  =[NSMutableArray array];
    if ([QQApiInterface isQQInstalled]) {
        [titleArray addObjectsFromArray:@[@"微信",@"朋友圈"]];
        [imageArray addObjectsFromArray:@[@"fx_wxhy",@"fx_pyq"]];
    }
    
    if ([WXApi isWXAppInstalled]) {
        [titleArray addObject:@"QQ"];
        [imageArray addObject:@"fx_qqhy"];
    }
    
    [titleArray addObject:@"微博"];
    [imageArray addObject:@"fx_wb"];
    
    NSMutableDictionary *platformDic = [NSMutableDictionary dictionary];
    [platformDic setValue:titleArray forKey:@"title"];
    [platformDic setValue:imageArray forKey:@"image"];
    return platformDic;
}

- (void)shareBtnClick:(ShareButton *)sender {
    switch (sender.tag) {
        case 1001:
        {
            [self startShare:WXSession];
        }
            break;
        case 1002:
        {
            [self startShare:WXTimeLine];
        }
            break;
        case 1003:
        {
            [self startShare:QQ];
        }
            break;
        case 1004:
        {
            [self startShare:Sina];
        }
            break;
            
        default:
            break;
    }
}

//开始分享
- (void)startShare:(NSInteger)name{
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareViewPlatformBtnClickWithTag:shareTitle:shareUrl:shareDesc:shareImage:respondVC:)]) {
        [self.delegate shareViewPlatformBtnClickWithTag:name shareTitle:_shareTitle shareUrl:_shareUrl shareDesc:_shareDesc shareImage:_shareImage respondVC:_respVC];
    }
}

//取消分享
- (void)cancelBtnClick:(UIButton *)sender{
    [self hidden];
}

- (void)hidden{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = kScreenHeight;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)show{
    CGRect frame = self.frame;
    frame.origin.y = kScreenHeight;
    self.frame = frame;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = kScreenHeight - self.frame.size.height;
        self.frame = frame;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
