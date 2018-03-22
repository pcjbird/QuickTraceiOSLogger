//
//  QuickTraceiOSLogger.h
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 2018/3/22.
//  Copyright © 2018年 Zero Status. All rights reserved.
//
//  框架名称:QuickTraceiOSLogger
//  框架功能:A real time iOS log trace tool, view iOS log with pc web browser under local area network, which will automatically scroll like xcode. 一个实时的iOS日志跟踪工具，在本地区域网络下使用 PC Web 浏览器查看 iOS 日志，它将像xcode一样自动滚动。
//  修改记录:
//     pcjbird    2018-03-22  Version:1.0.1 Build:201803220002
//                            1.修复iOS11上无法浏览日志的问题
//
//     pcjbird    2018-03-22  Version:1.0.0 Build:201803220001
//                            1.首次发布SDK版本
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//! Project version number for QuickTraceiOSLogger.
FOUNDATION_EXPORT double QuickTraceiOSLoggerVersionNumber;

//! Project version string for QuickTraceiOSLogger.
FOUNDATION_EXPORT const unsigned char QuickTraceiOSLoggerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <QuickTraceiOSLogger/PublicHeader.h>


#if __has_include("QuickiOSLogServer.h")
#import "QuickiOSLogServer.h"
#endif
