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
 *@brief 停止服务器
 */
+ (void)stop;

@end
