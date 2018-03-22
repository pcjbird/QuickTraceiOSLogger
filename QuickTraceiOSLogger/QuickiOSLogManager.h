//
//  QuickiOSLogManager.h
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 2018/3/22.
//  Copyright © 2018年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuickiOSLogMessage.h"

@interface QuickiOSLogManager : NSObject

/**
 *  利用ASL提供的接口获取日志
 *
 *  @param time 指定的时间
 *
 *  @return 获取到的日志
 */
+ (NSArray<QuickiOSLogMessage *> *)allLogAfterTime:(CFAbsoluteTime) time;

@end
