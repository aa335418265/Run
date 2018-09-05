//
//  YSModifyPasswordViewController.h
//  YSRun
//
//  Created by itx on 15/10/30.
//  Copyright © 2015年 msq. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YSModifyViewControllerDelegate <NSObject>

@required
- (void)modifyViewDidSelectedRelogin;

@end

@interface YSModifyPasswordViewController : UIViewController

- (id)initWithPhoneNumber:(NSString *)phoneNumber;


@property (nonatomic, weak) id<YSModifyViewControllerDelegate> delegate;

@end
