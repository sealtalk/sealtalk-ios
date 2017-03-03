//
//  Created by Caoyq on 16/5/23.
//  Copyright © 2016年 Caoyq. All rights reserved.
//

#ifndef YZHHCHeader_h
#define YZHHCHeader_h

#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define NSLog(...);
#endif

#endif /* HCHeader_h */
