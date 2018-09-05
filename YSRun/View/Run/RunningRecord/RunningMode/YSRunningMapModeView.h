//
//  YSRunningMapModeView.h
//  YSRun
//
//  Created by itx on 15/10/19.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSRunningModeView.h"

@class YSMapManager;

@interface YSRunningMapModeView : YSRunningModeView

- (YSMapManager *)getMapManager;
- (void)setupMap;
- (void)mapLocation;

@end
