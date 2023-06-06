//
//  QuickiOSLogServer.h
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 2018/3/22.
//  Copyright © 2018年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickiOSLogServer : NSObject

/**
 *@brief 启动服务器
 */
+ (void)start;

/**
 *@brief 启动服务器
 *@param suspendInBackground 是否在后台挂起
 *@param offlineDetectInterval 离线检测间隔时间，单位：秒，默认30s
 */
+ (void) start:(BOOL)suspendInBackground offlineDetectIntervalInSeconds:(NSInteger)offlineDetectInterval;

/**
 *@brief 停止服务器
 */
+ (void)stop;

@end
