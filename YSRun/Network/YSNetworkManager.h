//
//  YSNetworkManager.h
//  YSRun
//
//  Created by itx on 15/10/22.
//  Copyright © 2015年 msq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YSUserInfoResponseModel;
@class YSRunDatabaseModel;
@class YSRegisterInfoRequestModel;
@class YSUserDatabaseModel;
@class UIImage;
@class YSSetUserRequestModel;
@class YSThirdPartLoginResponseModel;


typedef void (^ITXAVUserResultBlock)(AVUser * _Nullable user,  NSError * _Nullable error);
typedef void (^ITXBooleanResultBlock)(BOOL succeeded,  NSError * _Nullable error);
typedef void (^ITXExistResultBlock)(BOOL existed,  NSError * _Nullable error);

@protocol YSNetworkManagerDelegate <NSObject>

@optional



// 验证码
- (void)showAcquireCaptchaResultTip:(NSString *)tip;
- (void)acquireCaptchaSuccess;
- (void)checkCaptchaSuccessWithPhoneNumber:(NSString *)phoneNumber;
- (void)checkCaptchaFailureWithMessage:(NSString *)message;

// 用户登录
- (void)loginSuccessWithUserInfoResponseModel:(YSUserInfoResponseModel *)userInfoResponseModel;
- (void)loginFailure;

// 数据同步
- (void)databaseSynchronizeRunDatas:(NSArray *)runDatas lastTime:(NSInteger)lastTime;
- (void)runDataEmptyInServer;

// 数据上传
- (void)uploadRunDataSuccessWithRowid:(NSInteger)rowid;
- (void)uploadRunDataFailure;

- (void)uploadRunDataSuccessWithRowid:(NSInteger)rowid lasttime:(NSString *)lasttime;
- (void)uploadRunDataFailureWithMessage:(NSString *)message;

// 用户注册
- (void)registerSuccessWithUid:(NSString *)uid;
- (void)registerFailureWithMessage:(NSString *)message;

// 重置密码验证码
- (void)acquireResetPasswordCaptchaSuccess;
- (void)acquireResetPasswordCaptchaFailureWithMessage:(NSString *)message;

// 重置密码
- (void)resetPasswordSuccess;
- (void)resetPasswordFailureWithMessage:(NSString *)message;

// 修改密码
- (void)modifyPasswordSuccess;
- (void)modifyPasswordFailureWithMessage:(NSString *)message;

// 设置信息
- (void)setInfoSuccess;
- (void)setInfoFailureWithMessage:(NSString *)message;

// 上传头像
- (void)uploadHeadImageSuccessWithPath:(NSString *)path;
- (void)uploadHeadImageFailureWithMessage:(NSString *)message;

// 获取用户信息
- (void)getUserInfoSuccessWithModel:(YSUserDatabaseModel *)model;
- (void)getUserInfoFailureWithMessage:(NSString *)message;

@end

@interface YSNetworkManager : NSObject

@property (nonatomic, weak) id<YSNetworkManagerDelegate> delegate;

- (void)acquireCaptchaWithPhoneNumber:(NSString *)phoneNumber;
//- (void)checkCaptcha:(NSString *)captcha phoneNumber:(NSString *)phoneNumber;
- (void)loginWithAccount:(NSString *)account password:(NSString *)password;
- (void)getRunDataWithUid:(NSString *)uid lastTime:(NSInteger)lastTime;

- (void)uploadRunData:(YSRunDatabaseModel *)runDatabaseModel;
- (void)userRegister:(YSRegisterInfoRequestModel *)registerInfo;
- (void)uploadHeadImage:(UIImage *)image uid:(NSString *)uid;

- (void)resetPasswordCaptchaWithPhoneNumber:(NSString *)phoneNumber;
//- (void)resetPassword:(NSString *)password phoneNumber:(NSString *)phoneNumber;
- (void)modifyPasswordWithPhoneNumber:(NSString *)phoneNumber oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;

- (void)getUserInfoWithUid:(NSString *)uid;
- (void)setUserWithRequestModel:(YSSetUserRequestModel *)setUserRequestModel;

// 第三方登录
- (void)thirdPartLoginWithThirdPartLoginResponseModel:(YSThirdPartLoginResponseModel *)model;


//////

//登录
- (void)login:(NSString *)phoneNumber  password:(NSString *)password callback:(ITXAVUserResultBlock)callback;

////验证手机验证码--忘记密码使用
//-(void)verifyMobilePhone:(NSString *)code withBlock:(ITXBooleanResultBlock)block;
- (void)resetPasswordWithSmsCode:(NSString *)code newPassword:(NSString *)password  callback:(ITXBooleanResultBlock)callback;

//请求重置密码验证码
- (void)requestPasswordResetCodeForPhoneNumber:(NSString *)phoneNumber  callback:(ITXBooleanResultBlock)callback;

//获取验证码
- (void)getCaptchaWithPhoneNumber:(NSString *)phoneNumber callback:(ITXBooleanResultBlock)callback;
//检查手机号码是否存在
- (void)checkPhoneIsExist:(NSString *)phoneNumber callback:(ITXExistResultBlock)callback;
//检查验证码是否正确
- (void)checkCaptcha:(NSString *)captcha phoneNumber:(NSString *)phoneNumber callback:(ITXBooleanResultBlock)callback;
/////

@end
