//
//  YSTimeLocationArray.h
//  YSRun
//
//  Created by itx on 16/1/26.
//  Copyright © 2016年 msq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSTimeLocationArray : NSObject

- (id)initWithLocationArray:(NSArray *)locationArray
             timestampArray:(NSArray *)timestampArray;

- (BOOL)hasTimeData;
- (NSArray *)getDataArray;

@end
