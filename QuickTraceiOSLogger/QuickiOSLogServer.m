//
//  QuickiOSLogServer.m
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 2018/3/22.
//  Copyright © 2018年 Zero Status. All rights reserved.
//

#import "QuickiOSLogServer.h"
#if __has_include(<XLFacility/XLFacility.h>)
#import <XLFacility/XLFacility.h>
#else
#import "XLFacility.h"
#endif
#import "QuickiOSHttpServerLogger.h"
#if __has_include(<XLFacility/XLFacilityMacros.h>)
#import <XLFacility/XLFacilityMacros.h>
#else
#import "XLFacilityMacros.h"
#endif
#if __has_include(<XLFacility/XLStandardLogger.h>)
#import <XLFacility/XLStandardLogger.h>
#else
#import "XLStandardLogger.h"
#endif
#import "QuickiOSLogServerOption.h"

@interface QuickiOSLogServer ()

@property (nonatomic, strong) QuickiOSHttpServerLogger *httpServerLogger;

@end

@implementation QuickiOSLogServer

static QuickiOSLogServer *_sharedServer = nil;

+ (QuickiOSLogServer *) sharedServer
{
    static dispatch_once_t onceToken;
    dispatch_block_t block = ^{
        if(!_sharedServer)
        {
            _sharedServer = [[self class] new];
        }
    };
    if ([NSThread isMainThread])
    {
        dispatch_once(&onceToken, block);
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            dispatch_once(&onceToken, block);
        });
    }
    return _sharedServer;
}

-(instancetype)init
{
    if(self = [super init])
    {
    }
    return self;
}

+(void)start
{
    [[QuickiOSLogServer sharedServer] startServer];
}


/**
 *@brief 启动服务器
 *@param suspendInBackground 是否在后台挂起
 *@param offlineDetectInterval 离线检测间隔时间，单位：秒，默认30s
 */
+ (void) start:(BOOL)suspendInBackground offlineDetectIntervalInSeconds:(NSInteger)offlineDetectInterval
{
    [QuickiOSLogServerOption sharedOption].suspendInBackground = suspendInBackground;
    [QuickiOSLogServerOption sharedOption].offlineDetectInterval = offlineDetectInterval;
    [[QuickiOSLogServer sharedServer] startServer];
}

+(void)stop
{
    [[QuickiOSLogServer sharedServer] stopServer];
}

-(QuickiOSHttpServerLogger *)httpServerLogger
{
    if (!_httpServerLogger)
    {
        _httpServerLogger = [[QuickiOSHttpServerLogger alloc] initWithPort:8080];
        _httpServerLogger.TCPServer.suspendInBackground = [QuickiOSLogServerOption sharedOption].suspendInBackground;
        
        _httpServerLogger.format = @"<td>%d %P[%p:%r] %m%c</td>";
    }
    return _httpServerLogger;
}
- (void)startServer
{
    [[XLStandardLogger sharedOutputLogger] setFormat:XLLoggerFormatString_NSLog];
    [[XLStandardLogger sharedErrorLogger] setFormat:XLLoggerFormatString_NSLog];
    [XLSharedFacility addLogger:[QuickiOSLogServer sharedServer].httpServerLogger];
    XLSharedFacility.minLogLevel = kXLLogLevel_Info;
    XLOG_INFO(@"[QuickTraceiOSLogger] 请在您的 PC 浏览器中打开 http://%@:%lu 浏览日志。", GCDTCPServerGetPrimaryIPAddress(false),(unsigned long)[QuickiOSLogServer sharedServer].httpServerLogger.TCPServer.port);
}

- (void)stopServer
{
    @try {
        if(_httpServerLogger)
        {
            NSLog(@"[QuickTraceiOSLogger] 日志跟踪服务已停止。");
            [_httpServerLogger close];
        }
    } @catch (NSException *exception) {
        NSLog(@"[QuickTraceiOSLogger] 停止日志跟踪服务发生异常:【%@】%@, 原因:%@。", exception.name, exception.description, exception.reason);
    } @finally {
        _httpServerLogger = nil;
    }
    
}

@end
