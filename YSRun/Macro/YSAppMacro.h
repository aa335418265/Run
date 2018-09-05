//
//  YSAppMacro.h
//  YSRun
//
//  Created by itx on 15/10/15.
//  Copyright © 2015年 msq. All rights reserved.
//

#ifndef YSAppMacro_h
#define YSAppMacro_h

// 颜色相关

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b)  RGBA(r,g,b,1.0)

#define GreenBackgroundColor   RGB(4,181,108)
//#define GreenBackgroundColor   RGB(0,128,255)
#define LightgrayBackgroundColor RGB(245, 245, 245)

#define ButtonCornerRadius 5

const static NSString *MapAPIKey = @"144a66ebaf4c0807624ccd64ef56d4a1";

#endif /* AppMacro_h */
