//
//  YSDevice.m
//  YSRun
//
//  Created by itx on 15/12/17.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSDevice.h"
#import <UIKit/UIKit.h>

@implementation YSDevice

+ (BOOL)isPhone6Plus
{
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale > 2.1) {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
