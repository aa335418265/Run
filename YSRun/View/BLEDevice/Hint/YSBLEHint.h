//
//  YSBLEHint.h
//  YSRun
//
//  Created by itx on 15/11/23.
//  Copyright © 2015年 msq. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol YSBLEHintDelegate <NSObject>

@required
- (void)BLEConnect;
- (void)runDirectly;

@end

@interface YSBLEHint : NSObject

@property (nonatomic, weak) id<YSBLEHintDelegate> delegate;

- (void)showConnectHint;
- (void)showConnectFailureHint;

@end
