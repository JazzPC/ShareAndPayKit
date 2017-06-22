# ShareAndPayKit
集成原生的分享、登录和支付功能，几行代码轻松搞定。

1.配置分享信息，并弹出分享平台选择框
```
- (IBAction)shareButtonPressed:(UIButton *)sender {
[ShareUtility shareWithUrl:@"http://www.baidu.com" title:@"你好" desc:@"测试分享" icon:[UIImage imageNamed:@"icon"] respVC:self];
}
```
2.QQ登录功能
```
[[AuthUtility shareInstance] qqLoginPressed];
[AuthUtility shareInstance].loginBlock = ^(NSDictionary *infoDic) {
//TODO:处理登录逻辑
if (infoDic != nil) {

}else {
NSLog(@"登录失败");
}
};
```
3.微信登录功能
```
[[AuthUtility shareInstance] wechatLoginPressed];
[AuthUtility shareInstance].loginBlock = ^(NSDictionary *infoDic) {
//TODO:处理登录逻辑
if (infoDic != nil) {

}else {
NSLog(@"登录失败");
}
};
```
4.微博登录功能
```
[[AuthUtility shareInstance] sinaLoginPressed];
[AuthUtility shareInstance].loginBlock = ^(NSDictionary *infoDic) {
//TODO:处理登录逻辑
if (infoDic != nil) {

}else {
NSLog(@"登录失败");
}
};
```
5.微信支付功能
```
- (IBAction)wechatPay:(UIButton *)sender {
//FIXME:方法参数需要服务端返回，这里暂时为nil
[[AuthUtility shareInstance] wechatPayPressed:nil];
}
```
6.支付宝支付功能
```
- (IBAction)aliPay:(UIButton *)sender {
//FIXME:方法参数需要服务端返回，这里暂时为nil
[[AuthUtility shareInstance] alipayPressed:nil];

}
```
