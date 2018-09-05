//
//  YSResetPasswordViewController.h
//  YSRun
//
//  Created by itx on 15/10/30.
//  Copyright © 2015年 msq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSResetPasswordViewController : UIViewController

- (id)initWithPhoneNumber:(NSString *)phoneNumber;
- (id)initWithPhoneNumber:(NSString *)phoneNumber code:(NSString *)code;
@end
