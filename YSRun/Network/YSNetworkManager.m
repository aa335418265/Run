//
//  YSNetworkManager.m
//  YSRun
//
//  Created by itx on 15/10/22.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSNetworkManager.h"
#import "YSNetworkRequest.h"
#import "YSUploadRunDataRequestModel.h"
#import "YSRunDatabaseModel.h"
#import "YSModifyPasswordRequestModel.h"
#import "YSSetUserRequestModel.h"
#import "YSThirdPartLoginResponseModel.h"

#import "YSLoadingHUD.h"
#import "YSTipLabelHUD.h"
#import "YSDataManager.h"
#import "YSUserInfoModel.h"
@interface YSNetworkManager () <YSNetworkRequestDelegate>

@property (nonatomic, strong) YSNetworkRequest *networkRequest;

@end

@implementation YSNetworkManager

- (id)init
{
    self = [super init];
    if (self)
    {
        self.networkRequest = [YSNetworkRequest shareNetworkRequest];
        self.networkRequest.delegate = self;
    }
    
    return self;
}

#pragma mark - public method
- (void)resetPasswordWithSmsCode:(NSString *)code newPassword:(NSString *)password  callback:(ITXBooleanResultBlock)callback {
    [AVUser resetPasswordWithSmsCode:code newPassword:password block:callback];
}

- (void)requestPasswordResetCodeForPhoneNumber:(NSString *)phoneNumber  callback:(ITXBooleanResultBlock)callback {
    [AVUser requestPasswordResetCodeForPhoneNumber:phoneNumber options:nil callback:callback];
}

- (void)login:(NSString *)phoneNumber  password:(NSString *)password callback:(ITXAVUserResultBlock)callback {
    [AVUser logInWithMobilePhoneNumberInBackground:phoneNumber password:password block:callback];
}

- (void)getCaptchaWithPhoneNumber:(NSString *)phoneNumber callback:(ITXBooleanResultBlock)callback {
    
    AVShortMessageRequestOptions *options = [[AVShortMessageRequestOptions alloc] init];
    options.TTL = 10;                      // 验证码有效时间为 10 分钟
    options.applicationName = @"易瘦我能行";  // 应用名称
    options.operation = @"注册";        // 操作名称
    [AVSMS requestShortMessageForPhoneNumber:phoneNumber
                                     options:options
                                    callback:callback];
}

- (void)checkPhoneIsExist:(NSString *)phoneNumber callback:(ITXExistResultBlock)callback{
    
    AVQuery *query = [AVUser query];
    [query whereKey:@"mobilePhoneNumber" equalTo:phoneNumber];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        callback ? callback(objects.count, error):nil ;
    }];
    
}

-(void)verifyMobilePhone:(NSString *)code withBlock:(ITXBooleanResultBlock)block {
    [AVUser verifyMobilePhone:code withBlock:block];
}
//检查验证码是否正确
- (void)checkCaptcha:(NSString *)captcha phoneNumber:(NSString *)phoneNumber callback:(ITXBooleanResultBlock)callback
{
    [AVOSCloud verifySmsCode:captcha mobilePhoneNumber:phoneNumber callback:callback];

}

- (void)loginWithAccount:(NSString *)account password:(NSString *)password
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.networkRequest userLoginWithAccount:account password:password delegate:self];
    });
}

- (void)getRunDataWithUid:(NSString *)uid lastTime:(NSInteger)lastTime

{

    AVQuery *query = [AVQuery queryWithClassName:@"RunData"];
    [query whereKey:@"uid" equalTo:uid];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"查询结果:%@", objects);
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objects.count];
            for (AVObject *obj in objects) {
                NSDictionary *dict =[obj objectForKey:@"localData"];
                YSRunDatabaseModel *model = [self runDatabaseModelFromDataDictionary:dict uid:uid];
                [arr addObject:model];
            }
            [self.delegate databaseSynchronizeRunDatas:arr lastTime:[[NSDate date] timeIntervalSince1970]];
        }

    }];
}


- (YSRunDatabaseModel *)runDatabaseModelFromDataDictionary:(NSDictionary *)dataDict uid:(NSString *)uid
{
    YSRunDatabaseModel *runDatabaseModel = [YSRunDatabaseModel new];
    
    runDatabaseModel.uid = uid;
    runDatabaseModel.isUpdate = 1;
    
    runDatabaseModel.bdate = [[dataDict valueForKey:@"bdate"] integerValue];
    runDatabaseModel.cost = [[dataDict valueForKey:@"cost"] integerValue];
    runDatabaseModel.distance = [[dataDict valueForKey:@"distance"] floatValue];
    runDatabaseModel.speed = [[dataDict valueForKey:@"speed"] floatValue];
    runDatabaseModel.star = [[dataDict valueForKey:@"star"] integerValue];
    runDatabaseModel.hSpeed = [[dataDict valueForKey:@"h_speed"] floatValue];
    runDatabaseModel.date = [dataDict valueForKey:@"date"];
    runDatabaseModel.pace = [[dataDict valueForKey:@"pace"] floatValue];
    runDatabaseModel.lSpeed = [[dataDict valueForKey:@"l_speed"] floatValue];
    runDatabaseModel.usetime = [[dataDict valueForKey:@"usetime"] integerValue];
    
    runDatabaseModel.heartRateDataString = [dataDict valueForKey:@"heartdata"];
    runDatabaseModel.locationDataString = [dataDict valueForKey:@"location"];
    
    return runDatabaseModel;
}

- (void)uploadRunData:(YSRunDatabaseModel *)runDatabaseModel
{
    YSUploadRunDataRequestModel *runData = [self uploadRunDataRequestFromRunDatabaseModel:runDatabaseModel];
    
    
    // 上传单次跑步数据
    
    YSUserInfoModel *userInfo = [[YSDataManager shareDataManager] getUserInfo];

    
    NSString *uid = (runData.uid != nil) ? runData.uid : userInfo.uid;
    NSNumber *pace = [NSNumber numberWithFloat:runData.pace];
    NSNumber *distance = [NSNumber numberWithFloat:runData.distance];
    NSNumber *usetime = [NSNumber numberWithInteger:runData.usetime];
    NSNumber *cost = [NSNumber numberWithInteger:runData.cost];
    NSNumber *star = [NSNumber numberWithInteger:runData.star];
    NSNumber *h_speed = [NSNumber numberWithFloat:runData.h_speed];
    NSNumber *l_speed = [NSNumber numberWithFloat:runData.l_speed];
    NSString *date = (runData.date != nil) ? runData.date : (NSString *)[NSNull null];
    NSNumber *bdate = [NSNumber numberWithInteger:runData.bdate];
    
    // Android那边的是毫秒。。服务器处理的时候除了个1000，所以。。否则date字段会为1970..
    NSNumber *edate = [NSNumber numberWithInteger:runData.edate * 1000];
    NSNumber *speed = [NSNumber numberWithFloat:runData.speed];
    
    // 这2个字段暂时没有数据。
    NSString *ctime = (NSString *)[NSNull null];
    NSString *utime = (NSString *)[NSNull null];
    
    NSString *location = (runData.locationDataString != nil) ? runData.locationDataString : (NSString *)[NSNull null];
    NSString *heartdata = (runData.heartRateDataString != nil) ? runData.heartRateDataString : (NSString *)[NSNull null];

    
    AVObject *obj = [[AVObject alloc] initWithClassName:@"RunData"];// 构建对象
    [obj setObject:uid forKey:@"uid"];// 设置名称
    [obj setObject:pace forKey:@"pace"];// 设置名称
    [obj setObject:distance forKey:@"distance"];// 设置名称
    [obj setObject:usetime forKey:@"usetime"];// 设置名称
    [obj setObject:cost forKey:@"cost"];// 设置名称
    [obj setObject:star forKey:@"star"];// 设置名称
    [obj setObject:h_speed forKey:@"h_speed"];// 设置名称
    [obj setObject:l_speed forKey:@"l_speed"];// 设置名称
    [obj setObject:date forKey:@"date"];// 设置名称
    [obj setObject:bdate forKey:@"bdate"];// 设置名称
    [obj setObject:edate forKey:@"edate"];// 设置名称
    [obj setObject:speed forKey:@"speed"];// 设置名称
    [obj setObject:ctime forKey:@"ctime"];// 设置名称
    [obj setObject:utime forKey:@"utime"];// 设置名称
    [obj setObject:location forKey:@"location"];// 设置名称
    [obj setObject:heartdata forKey:@"heartdata"];// 设置名称
    
    
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            
            NSDate *currentDate = [NSDate date];
            //用于格式化NSDate对象
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设置格式：zzz表示时区
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            //NSDate转NSString
            
            NSString *currentDateString = [dateFormatter stringFromDate:currentDate];

            [self uploadUserRunDataSuccessWithlocalRowid:runData.rowid lasttime:currentDateString];
        }else{
            NSLog(@"存储失败");
        }
    }];
    
    
    
}

- (void)userRegister:(YSRegisterInfoRequestModel *)registerInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.networkRequest userRegisterWithRequestModel:registerInfo delegate:self];
    });
}

- (void)uploadHeadImage:(UIImage *)image uid:(NSString *)uid
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.networkRequest uploadHeadImage:image uid:uid delegate:self];
    });
}

- (void)resetPasswordCaptchaWithPhoneNumber:(NSString *)phoneNumber
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.networkRequest resetPasswordCaptchaWithPhoneNumber:phoneNumber delegate:self];
    });
}

//- (void)resetPassword:(NSString *)password phoneNumber:(NSString *)phoneNumber
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
//        [self.networkRequest resetPasswordWithAccount:phoneNumber password:password delegate:self];
//    });
//}

- (void)modifyPasswordWithPhoneNumber:(NSString *)phoneNumber oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        YSModifyPasswordRequestModel *modiyPasswordModel = [YSModifyPasswordRequestModel new];
        modiyPasswordModel.phone = phoneNumber;
        modiyPasswordModel.oldPassword = oldPassword;
        modiyPasswordModel.modifiedPassword = newPassword;
        
        [self.networkRequest modiyPasswordWithRequestModel:modiyPasswordModel delegate:self];
    });
}

- (void)getUserInfoWithUid:(NSString *)uid
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.networkRequest getUserInfoWithUserID:uid delegate:self];
    });
}

- (void)setUserWithRequestModel:(YSSetUserRequestModel *)setUserRequestModel
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.networkRequest setUserWithRequestModel:setUserRequestModel delegate:self];
    });
}

- (void)thirdPartLoginWithThirdPartLoginResponseModel:(YSThirdPartLoginResponseModel *)model
{
    // 第三方登录，将对应字段向服务器进行请求
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [self.networkRequest thirdPartLoginWithModel:model delegate:self];
    });
    
}

#pragma mark - private method

- (void)acquireCaptchaResult:(NSString *)result
{
    if ([self.delegate respondsToSelector:@selector(showAcquireCaptchaResultTip:)])
    {
        [self.delegate showAcquireCaptchaResultTip:result];
    }
}

- (void)checkCaptchaFailureResult:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(checkCaptchaFailureWithMessage:)])
    {
        [self.delegate checkCaptchaFailureWithMessage:message];
    }
}

#pragma mark - YSNetworkRequestDelegate

// 获取验证码
- (void)acquireCaptchaSuccess
{
    if ([self.delegate respondsToSelector:@selector(acquireCaptchaSuccess)])
    {
        [self.delegate acquireCaptchaSuccess];
    }
}

- (void)acquireCaptchaFailure
{
    NSString *tipText = @"验证码请求失败";
    [self acquireCaptchaResult:tipText];
}

- (void)registerPhoneNumberHasExsist
{
    NSString *tipText = @"手机号已存在";
    [self acquireCaptchaResult:tipText];
}





// 用户注册
- (void)userRegisterSuccessWithUid:(NSString *)uid
{
    // 用户注册成功之后返回uid，此时拿uid再向服务器请求用户数据.
    if ([self.delegate respondsToSelector:@selector(registerSuccessWithUid:)])
    {
        [self.delegate registerSuccessWithUid:uid];
    }
}

- (void)userRegisterFailureWithMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(registerFailureWithMessage:)])
    {
        [self.delegate registerFailureWithMessage:message];
    }
}

- (void)userRegisterPhoneNumberCaptchaCorrect
{
    
}

// 用户登录
- (void)userLoginSuccessWithUserInfoResponseModel:(YSUserInfoResponseModel *)userModel
{
    if ([self.delegate respondsToSelector:@selector(loginSuccessWithUserInfoResponseModel:)])
    {
        [self.delegate loginSuccessWithUserInfoResponseModel:userModel];
    }
}

- (void)userLoginFailure
{
    if ([self.delegate respondsToSelector:@selector(loginFailure)])
    {
        [self.delegate loginFailure];
    }
}

// 重置密码前的验证码
- (void)acquireResetPasswordCaptchaSuccess
{
    if ([self.delegate respondsToSelector:@selector(acquireResetPasswordCaptchaSuccess)])
    {
        [self.delegate acquireResetPasswordCaptchaSuccess];
    }
}

- (void)acquireResetPasswordCaptchaFailureWithMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(acquireResetPasswordCaptchaFailureWithMessage:)])
    {
        [self.delegate acquireResetPasswordCaptchaFailureWithMessage:message];
    }
}

// 密码重置
- (void)userResetPasswordSuccess
{
    if ([self.delegate respondsToSelector:@selector(resetPasswordSuccess)])
    {
        [self.delegate resetPasswordSuccess];
    }
}

- (void)userResetPasswordFailureWithMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(resetPasswordFailureWithMessage:)])
    {
        [self.delegate resetPasswordFailureWithMessage:message];
    }
}

// 修改密码
- (void)userModifyPasswordSuccess
{
    if ([self.delegate respondsToSelector:@selector(modifyPasswordSuccess)])
    {
        [self.delegate modifyPasswordSuccess];
    }
}

- (void)userModifyPasswordFailureWithMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(modifyPasswordFailureWithMessage:)])
    {
        [self.delegate modifyPasswordFailureWithMessage:message];
    }
}

// 设置用户基本信息
- (void)userSetInfoSuccess
{
    if ([self.delegate respondsToSelector:@selector(setInfoSuccess)])
    {
        [self.delegate setInfoSuccess];
    }
}

- (void)userSetInfoFailureWithMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(setInfoFailureWithMessage:)])
    {
        [self.delegate setInfoFailureWithMessage:message];
    }
}

// 获取用户基本信息
- (void)requestUserInfoSuccessWithModel:(YSUserDatabaseModel *)model
{
    if ([self.delegate respondsToSelector:@selector(getUserInfoSuccessWithModel:)])
    {
        [self.delegate getUserInfoSuccessWithModel:model];
    }
}

- (void)requestUserInfoFailureWithMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(getUserInfoFailureWithMessage:)])
    {
        [self.delegate getUserInfoFailureWithMessage:message];
    }
}

// 上传跑步数据

- (void)uploadUserRunDataSuccessWithlocalRowid:(NSInteger)rowid lasttime:(NSString *)lasttime
{
    if ([self.delegate respondsToSelector:@selector(uploadRunDataSuccessWithRowid:lasttime:)])
    {
        [self.delegate uploadRunDataSuccessWithRowid:rowid lasttime:lasttime];
    }
}

- (void)uploadUserRunDataFailureWithMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(uploadRunDataFailureWithMessage:)])
    {
        [self.delegate uploadRunDataFailureWithMessage:message];
    }
}

// 获取服务端跑步数据
- (void)synchronizeLocalRunData:(NSArray *)runDataArray lastTime:(NSInteger)lastTime
{
    if ([self.delegate respondsToSelector:@selector(databaseSynchronizeRunDatas:lastTime:)])
    {
        [self.delegate databaseSynchronizeRunDatas:runDataArray lastTime:lastTime];
    }
}

- (void)notRequiredSynchronized
{
    
}

- (void)getRunDataEmpty
{
    if ([self.delegate respondsToSelector:@selector(runDataEmptyInServer)])
    {
        [self.delegate runDataEmptyInServer];
    }
}

// 上传头像
- (void)userUploadHeadImageSuccessWithPath:(NSString *)imagePath
{
    if ([self.delegate respondsToSelector:@selector(uploadHeadImageSuccessWithPath:)])
    {
        [self.delegate uploadHeadImageSuccessWithPath:imagePath];
    }
}

- (void)userUploadHeadImageFailureWithMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(uploadHeadImageFailureWithMessage:)])
    {
        [self.delegate uploadHeadImageFailureWithMessage:message];
    }
}

// 网络请求失败
- (void)networkRequestFailureWithError:(NSError *)error
{
    // 网络请求失败，一般出现在断网的情况下
    [[YSLoadingHUD shareLoadingHUD] dismiss];
    [[YSTipLabelHUD shareTipLabelHUD] showTipWithText:@"网络请求超时，请检查网络连接状况"];
}

#pragma mark - private

- (YSUploadRunDataRequestModel *)uploadRunDataRequestFromRunDatabaseModel:(YSRunDatabaseModel *)runDatabaseModel
{
    YSUploadRunDataRequestModel *requestModel = [YSUploadRunDataRequestModel new];
    
    requestModel.rowid = runDatabaseModel.rowid;
    requestModel.uid = runDatabaseModel.uid;
    requestModel.pace = runDatabaseModel.pace;
    requestModel.distance = runDatabaseModel.distance;
    requestModel.usetime = runDatabaseModel.usetime;
    requestModel.cost = runDatabaseModel.cost;
    requestModel.star = runDatabaseModel.star;
    requestModel.h_speed = runDatabaseModel.hSpeed;
    requestModel.l_speed = runDatabaseModel.lSpeed;
    requestModel.date = runDatabaseModel.date;
    requestModel.edate = runDatabaseModel.edate;
    requestModel.bdate = runDatabaseModel.bdate;
    requestModel.speed = runDatabaseModel.speed;
    
    requestModel.locationDataString = runDatabaseModel.locationDataString;
    requestModel.heartRateDataString = runDatabaseModel.heartRateDataString;
    
    return requestModel;
}

@end
