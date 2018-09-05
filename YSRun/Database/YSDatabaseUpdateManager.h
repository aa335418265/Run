//
//  YSDatabaseUpdateManager.h
//  YSRun
//
//  Created by itx on 15/12/28.
//  Copyright © 2015年 msq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface YSDatabaseUpdateManager : NSObject

+ (void)setDefaultVersion;

- (void)setDatabaseVersion:(NSInteger)version;
- (void)checkVersionWithDatabase:(FMDatabase *)database;
- (BOOL)hasSetVersion;

@end
