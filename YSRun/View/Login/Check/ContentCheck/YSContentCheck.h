//
//  YSContentCheck.h
//  YSRun
//
//  Created by itx on 16/1/13.
//  Copyright © 2016年 msq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UITextField;

@interface YSContentCheck : NSObject

- (void)checkWithTextField:(UITextField *)textField beginText:(NSString *)beginText endText:(NSString *)endText;

@end
