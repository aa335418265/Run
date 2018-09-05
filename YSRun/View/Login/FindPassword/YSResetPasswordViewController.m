//
//  YSResetPasswordViewController.m
//  YSRun
//
//  Created by itx on 15/10/30.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSResetPasswordViewController.h"
#import "YSNavigationBarView.h"
#import "YSAppMacro.h"
#import "YSNetworkManager.h"
#import "YSTipLabelHUD.h"
#import "YSLoginViewController.h"
#import "YSUtilsMacro.h"
#import "YSLoadingHUD.h"
#import "YSDevice.h"
#import "YSTextFieldComponentCreator.h"
#import "YSCaptchaTimer.h"
#import "YSTextFieldDelegateObj.h"
#import "YSContentCheckIconChange.h"

@interface YSResetPasswordViewController () <YSNetworkManagerDelegate, YSContentCheckIconChangeDelegate, YSTextFieldDelegateObjCallBack>

@property (nonatomic, weak) IBOutlet YSNavigationBarView *navigationBarView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *sumbitButton;

@property (nonatomic, strong) UIButton *captchaButton;      // 发送验证码按钮

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *code;

@property (nonatomic, weak) IBOutlet UITextField *captchaTextField;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *textFieldHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *captchaTextFieldHeightConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *textFieldTopToBarViewBottomConstraint;

@property (nonatomic, strong) YSTextFieldDelegateObj *textFieldDelegateObj;
@property (nonatomic, strong) YSTextFieldDelegateObj *captchaTextFieldDelegateObj;

@end

@implementation YSResetPasswordViewController

- (id)initWithPhoneNumber:(NSString *)phoneNumber code:(NSString *)code
{
    self = [super init];
    if (self)
    {
        self.phoneNumber = phoneNumber;
        self.code = code;
    }
    
    return self;
}

- (id)initWithPhoneNumber:(NSString *)phoneNumber
{
    self = [super init];
    if (self)
    {
        self.phoneNumber = phoneNumber;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationBarView setupWithTitle:@"重置密码" barBackgroundColor:[UIColor clearColor] target:self action:@selector(resetPasswordViewBack)];
    
    // 在此处改变constant并不会导致对应控件的高度立即变化，所以setup方法中需要控件高度的地方直接取constant的值
    self.textFieldTopToBarViewBottomConstraint.constant = [self constraintConstant];
    if ([YSDevice isPhone6Plus])
    {
        self.textFieldHeightConstraint.constant = 52;
        self.captchaTextFieldHeightConstraint.constant = 52;
    }
    
    [self setupButton];
    [self setupTextField];
    [self setupBackgroundImage];
    [self addBackgroundTapGesture];
    [self sendCaptchaSuccess];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetCaptchaButtonState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)captchaButtonClicked:(UIButton *)button
{
    NSString *phoneNumber = self.phoneNumber;
    YSNetworkManager *networkManager = [YSNetworkManager new];
    [networkManager requestPasswordResetCodeForPhoneNumber:phoneNumber callback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self acquireResetPasswordCaptchaSuccess];
        }else{
            [[YSTipLabelHUD shareTipLabelHUD] showTipWithError:error];
        }
    }];
    
    [self sendCaptchaSuccess];
}

///

- (void)resetCaptchaButtonState
{
    // 根据单例里保存的数据来设置发送验证码按钮的状态
    
    YSCaptchaTimer *captchaTimer = [YSCaptchaTimer shareCaptchaTimer];
    
    if ([captchaTimer isCountdownState])
    {
        [self setCaptchaButtonDisabled];
        
        CallbackBlock block = [self getCaptchaTimerCallBackBlock];
        [captchaTimer setCallbackWithBlock:block];
    }
}

- (void)sendCaptchaSuccess
{
    // 发送验证码按钮置灰，倒计时完成后才能点击。
    
    [[YSCaptchaTimer shareCaptchaTimer] startWithBlock:[self getCaptchaTimerCallBackBlock]];
    [self setCaptchaButtonDisabled];
}

- (void)setCaptchaButtonDisabled
{

    self.captchaButton.enabled = NO;
}

- (CallbackBlock)getCaptchaTimerCallBackBlock
{
    CallbackBlock block = ^(NSInteger remainTime, BOOL finished)
    {
        UIButton *captchaButton = self.captchaButton;
        if (finished)
        {
            captchaButton.enabled = YES;
            //            captchaButton.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            NSString *text = [NSString stringWithFormat:@"%@s", @(remainTime)];
            
            // 需同时设置，，并且保证captchaButton.titleLabel.text在setTitle:forState:之前，否则按钮的字在NSTimer调用时会闪。
            captchaButton.titleLabel.text = text;
            [captchaButton setTitle:text forState:UIControlStateDisabled];
            [captchaButton setTitleColor:GreenBackgroundColor forState:UIControlStateDisabled];
        }
    };
    
    return block;
}

///

- (void)setupButton
{
    [self.sumbitButton setTitle:@"提  交" forState:UIControlStateNormal];
    [self.sumbitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
//    CGFloat btnHeight = self.textFieldHeightConstraint.constant;
    self.sumbitButton.layer.cornerRadius = ButtonCornerRadius;
    
    self.sumbitButton.backgroundColor = GreenBackgroundColor;
    self.sumbitButton.clipsToBounds = YES;
}

- (void)setupBackgroundImage
{
    // 设置背景图片
    UIImage *image = [UIImage imageNamed:@"login_background"];
    self.view.layer.contents = (id)image.CGImage;
}

- (void)addBackgroundTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapBackground:(id)tapGesture
{
    // 点击背景处时收起键盘。
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)setupTextField
{
    CGFloat textFieldHeight = CGRectGetHeight(self.textField.frame);
    [YSTextFieldComponentCreator setupTextField:self.textField height:textFieldHeight];
    
    UIImage *image = [YSTextFieldComponentCreator getPasswordIconWithContentEmptyState:YES];
    self.textField.leftView = [YSTextFieldComponentCreator getViewWithImage:image textFieldHeight:textFieldHeight];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    [YSTextFieldComponentCreator setupTextField:self.textField withPlaceholder:@"请设置新密码"];
    
    self.textField.secureTextEntry = YES;
    
    UIButton *secureTextButton = [self getSecureTextButton];
    self.textField.rightView = [YSTextFieldComponentCreator getViewWithPasswordSecureButton:secureTextButton buttonWidth:56 textFieldHeight:textFieldHeight];
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.enablesReturnKeyAutomatically = YES;
    
    //验证码按钮
    
    // 发送验证码按钮
    self.captchaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.captchaButton addTarget:self action:@selector(captchaButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *accountImage = [YSTextFieldComponentCreator getSmsCodeIconWithContentEmptyState:YES];
    self.captchaTextField.leftView = [YSTextFieldComponentCreator getViewWithImage:accountImage textFieldHeight:textFieldHeight];
    self.captchaTextField.leftViewMode = UITextFieldViewModeAlways;
    self.captchaTextField.keyboardType = UIKeyboardTypePhonePad;
    self.captchaTextField.enablesReturnKeyAutomatically = YES;
    // 占位符
    [YSTextFieldComponentCreator setupTextField:self.captchaTextField withPlaceholder:@"请输入验证码"];
    
    CGFloat buttonWidth = [YSDevice isPhone6Plus] ? 96 : 76;
    self.captchaTextField.rightView = [YSTextFieldComponentCreator getViewWithCaptchaButton:self.captchaButton buttonWidth:buttonWidth textFieldHeight:textFieldHeight];
    self.captchaTextField.rightViewMode = UITextFieldViewModeAlways;

    self.captchaTextField.returnKeyType = UIReturnKeyDone;
    
    
    [self setupTextFieldDelegate];
}

- (void)setupTextFieldDelegate
{
    // 给文本框设置代理，有输入字符时文本框左边图标改变
    
    YSContentCheckIconChange *contentCheck = [[YSContentCheckIconChange alloc] initWithDelegate:self];
    NSArray *contentCheckArray = @[contentCheck];
    
    self.textFieldDelegateObj = [[YSTextFieldDelegateObj alloc] initWithEditingCheckArray:nil contentCheckArray:contentCheckArray];
    self.textField.delegate = self.textFieldDelegateObj;
    
    self.textFieldDelegateObj.delegate = self;
    
    YSContentCheckIconChange *contentCheck2 = [[YSContentCheckIconChange alloc] initWithDelegate:self];
    NSArray *contentCheckArray2 = @[contentCheck2];
    self.captchaTextFieldDelegateObj = [[YSTextFieldDelegateObj alloc] initWithEditingCheckArray:nil contentCheckArray:contentCheckArray2];
    self.captchaTextField.delegate = self.captchaTextFieldDelegateObj;
    
    self.captchaTextFieldDelegateObj.delegate = self;
}

- (UIButton *)getSecureTextButton
{
    UIButton *secureTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [secureTextButton addTarget:self action:@selector(secureTextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *image = [UIImage imageNamed:@"password_eye_close"];
    [secureTextButton setImage:image forState:UIControlStateNormal];
    
    return secureTextButton;
}

- (void)secureTextButtonClicked:(UIButton *)button
{
    self.textField.secureTextEntry = !self.textField.secureTextEntry;
    
    UIImage *image = self.textField.secureTextEntry ? [UIImage imageNamed:@"password_eye_close"] : [UIImage imageNamed:@"password_eye_open"];
    [button setImage:image forState:UIControlStateNormal];
}

- (CGFloat)constraintConstant
{
    // 根据实际情况计算的constant值，既第一个文本框与导航栏的距离
    
    CGFloat distance = 5;   // 控件间的间距
    CGFloat height = self.textFieldHeightConstraint.constant;   // 控件的高度，文本框和按钮的高度相同
    CGFloat barViewHeight = CGRectGetHeight(self.navigationBarView.frame);
    
    CGFloat screenHeight = [UIApplication sharedApplication].keyWindow.frame.size.height;
    // 按钮距底边的间距为第一个文本框距导航栏的间距的2倍
    CGFloat constant = (screenHeight - barViewHeight - height * 2 - distance) / 3;
    
    return constant;
}

- (IBAction)submitButtonClicked:(id)sender
{
    [self resetPassword];
}

- (void)resetPassword
{
    NSString *newPassword = self.textField.text;
    
    if ([newPassword length] < 1)
    {
        NSString *tip = @"密码不能为空";
        [self showTipLabelWithText:tip];
        return;
    }
    
    [[YSLoadingHUD shareLoadingHUD] show];
    
    YSNetworkManager *networkManager = [YSNetworkManager new];
    [networkManager resetPasswordWithSmsCode:self.code newPassword:newPassword callback:^(BOOL succeeded, NSError * _Nullable error) {
        [[YSLoadingHUD shareLoadingHUD] dismiss];
        if (succeeded) {
            [self resetPasswordSuccess];
        }else{
            [[YSTipLabelHUD shareTipLabelHUD] showTipWithError:error];
        }
    }];

}

- (void)showTipLabelWithText:(NSString *)text
{
    [[YSTipLabelHUD shareTipLabelHUD] showTipWithText:text];
}

- (void)resetPasswordViewBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - YSNetworkManagerDelegate

- (void)resetPasswordSuccess
{
    // 重置密码成功后跳转到登录界面
    
    [[YSLoadingHUD shareLoadingHUD] dismiss];
    
    [[YSTipLabelHUD shareTipLabelHUD] showTipWithText:@"密码重置成功"];
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    UIViewController *popToViewController = nil;
    
    for (UIViewController *viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[YSLoginViewController class]])
        {
            popToViewController = viewController;
            break;
        }
    }
    
    [self.navigationController popToViewController:popToViewController animated:YES];
}

- (void)resetPasswordFailureWithMessage:(NSString *)message
{
    [[YSLoadingHUD shareLoadingHUD] dismiss];
    
    [[YSTipLabelHUD shareTipLabelHUD] showTipWithText:message];
}

- (void)needChangeTextField:(UITextField *)textField textEmpty:(BOOL)isEmpty
{
    CGFloat textFieldHeight = CGRectGetHeight(textField.frame);
    UIImage *image = nil;
    
    if (textField == self.textField)
    {
        image = [YSTextFieldComponentCreator getPasswordIconWithContentEmptyState:isEmpty];
    }
    else if (textField == self.captchaTextField)
    {
        image = [YSTextFieldComponentCreator getSmsCodeIconWithContentEmptyState:isEmpty];
    }
    
    textField.leftView = [YSTextFieldComponentCreator getViewWithImage:image textFieldHeight:textFieldHeight];
    
    
}

#pragma mark - YSTextFieldDelegateObjCallBack

- (void)textFieldDidReturn:(UITextField *)textField
{
    if (textField == self.textField)
    {
        [self resetPassword];
    }
}

@end
