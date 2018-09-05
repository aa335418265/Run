//
//  YSLocusView.h
//  YSRun
//
//  Created by itx on 16/1/25.
//  Copyright © 2016年 msq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YSDataRecordModel;

@interface YSLocusView : UIView

- (void)setupWithDataRecordModel:(YSDataRecordModel *)dataRecordModel;
- (UIImage *)getMapScreenShot;

@end
