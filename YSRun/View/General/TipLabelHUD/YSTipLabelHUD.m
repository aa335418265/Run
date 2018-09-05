//
//  YSTipLabelHUD.m
//  YSRun
//
//  Created by itx on 15/10/22.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSTipLabelHUD.h"
#import <UIKit/UIKit.h>
#import "YSAppMacro.h"
#import <AVConstants.h>

@interface YSTipLabelHUD ()

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation YSTipLabelHUD

static YSTipLabelHUD *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    //调用dispatch_once保证在多线程中也只被实例化一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)shareTipLabelHUD
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YSTipLabelHUD alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initTipLabel];
    }
    
    return self;
}

- (void)initTipLabel
{
    self.tipLabel = [UILabel new];
    
    self.tipLabel.textColor = [UIColor whiteColor];
    self.tipLabel.backgroundColor = RGBA(0, 0, 0, 0.75);
    self.tipLabel.font = [UIFont systemFontOfSize:15];
    self.tipLabel.numberOfLines = 0;
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    
    self.tipLabel.layer.cornerRadius = 5;
    self.tipLabel.clipsToBounds = YES;
}

- (void)resizeLabel
{
    // 根据文本内容调整标签大小
    UIFont *font = self.tipLabel.font;
    NSString *text = self.tipLabel.text;
    
    CGSize size = CGSizeMake(320,2000);
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize labelSize = [text boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    
    CGFloat d = 10;     // 字体和标签边缘的间距
    self.tipLabel.frame = CGRectMake(self.tipLabel.frame.origin.x, self.tipLabel.frame.origin.y,
                                     labelSize.width + 2 * d, labelSize.height + 2 * d);
}

- (void)showTipWithError:(NSError *)error {
    NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
    id obj = [dictFromData objectForKey:@"code"];
    
    if (obj) {
        NSInteger code = [obj longValue];
        [self showTipWithCode:code];
    }

}

- (void)showTipWithCode:(NSInteger)code {
    NSString *message = nil;
    switch (code) {
        case 210:
            message = @"密码错误";
            break;
        case 211:
            message = @"找不到用户";
            break;
        case 213:
            message = @"手机号码对应的用户不存在";
            break;
        case 214:
            message = @"手机号码已经被注册";
            break;
        case 215:
            message = @"未验证的手机号码";
            break;
        case 218:
            message = @"无效的密码，不允许空白密码";
            break;
        case 219:
            message = @"登录失败次数超过限制，请稍候再试";
            break;
        case 600:
            message = @"无效的短信签名";
            break;
        case 601:
            message = @"发送短信过于频繁";
            break;
        case 602:
            message = @"发送短信验证码失败";
            break;
        case 603:
            message = @"无效的短信验证码";
            break;
            
        default:
            break;
    }
    [self showTipWithText:message];
}

- (void)showTipWithText:(NSString *)text
{
    self.tipLabel.text = text;
    [self resizeLabel];
    
    [self showTip];
}

- (void)showTip
{
    UIWindow *window = [self getWindow];
    if (window)
    {
        // 显示在屏幕
        
//        CGFloat distance = 88;  // 标签距离屏幕底边的距离
        CGFloat windowWidth = CGRectGetWidth(window.frame);
        CGFloat windowHeight = CGRectGetHeight(window.frame);
        
        CGFloat labelWidth = CGRectGetWidth(self.tipLabel.frame);
        CGFloat labelHeight = CGRectGetHeight(self.tipLabel.frame);
        CGRect labelFrame = CGRectMake((windowWidth - labelWidth) / 2, (windowHeight - labelHeight) / 3 + 52, labelWidth, labelHeight);
        
        self.tipLabel.frame = labelFrame;
        
        if (![self.tipLabel superview])
        {
            [window addSubview:self.tipLabel];
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(hideTip) withObject:nil afterDelay:[self autoHideTimeWithString:self.tipLabel.text]];
    }
}

- (void)hideTip
{
    [self.tipLabel removeFromSuperview];
}

- (UIWindow *)getWindow
{
    __block UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if ([window isMemberOfClass:[UIWindow class]] == NO)
    {
        [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isMemberOfClass:[UIWindow class]]) {
                window = obj;
            }
            *stop = YES;
        }];
    }
    
    return window;
}

- (NSTimeInterval)autoHideTimeWithString:(NSString *)string
{
    return string.length * 0.13 > 1.5? string.length * 0.13:1.5;
}


@end
