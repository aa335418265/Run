//
//  YSGraph.h
//  PieChartDemo
//
//  Created by itx on 15/11/12.
//  Copyright © 2015年 msq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YSGraphData;

@interface YSGraph : UIView

- (void)setupWithGraphData:(YSGraphData *)graphData;
- (NSArray *)getPoints;

@end
