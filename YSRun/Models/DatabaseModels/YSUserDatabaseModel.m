//
//  YSUserDatabaseModel.m
//  YSRun
//
//  Created by itx on 15/10/26.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSUserDatabaseModel.h"

@implementation YSUserDatabaseModel

- (NSString *)uid {
    return _uid?_uid:@"";
}


- (NSString *)birthday {
    return _birthday?_birthday:@"";
}

- (NSString *)phone {
    return _phone?_phone:@"";
}
- (NSString *)nickname {
    return _nickname?_nickname:@"";
}
- (NSString *)lasttime {
    return _lasttime?_lasttime:@"";
}
- (NSString *)headimg {
    return _headimg?_headimg:@"";
}

@end
