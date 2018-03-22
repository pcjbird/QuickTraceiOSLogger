//
//  QuickiOSLogHttpServer.h
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 2018/3/22.
//  Copyright © 2018年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickiOSLogHttpServer : NSObject

/**
 *@brief 启动服务器
 */
+ (void)start;

/**
 *@brief 停止服务器
 */
+ (void)stop;

/**
 *@brief 服务器是否正在运行
 *@return YES，正在运行  NO，已停止运行
 */
+ (BOOL) isRunning;


/**
 *@brief 设置刷新时间
 *@param delay 刷新时间，单位：毫秒
 */
+ (void)setRefreshDelayInMilliSeconds:(NSTimeInterval)delay;

@end
