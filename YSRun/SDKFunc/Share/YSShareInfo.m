//
//  YSShareInfo.m
//  YSRun
//
//  Created by itx on 15/12/5.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSShareInfo.h"

@implementation YSShareInfo

+ (instancetype)defaultShareInfoWithImages:(NSArray *)images
{
    return [YSShareInfo defaultShareInfoWithImages:images contentText:nil];
}

+ (instancetype)defaultShareInfoWithImages:(NSArray *)images contentText:(NSString *)contentText
{
    YSShareInfo *shareInfo = [YSShareInfo new];
    shareInfo.imageArray = images;
    shareInfo.contentText = contentText;
    
    // 其他参数为默认值
    shareInfo.url = [NSURL URLWithString:@"http://www.baidu.com"];
    shareInfo.title = @"易瘦我能行";
    
    return shareInfo;
}

@end
