//
//  QuickiOSLogServer.m
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 2018/3/22.
//  Copyright © 2018年 Zero Status. All rights reserved.
//

#import "QuickiOSLogServer.h"
#import <XLFacility/XLFacility.h>
#import <XLFacility/XLTelnetServerLogger.h>
#import <XLFacility/XLHTTPServerLogger.h>
#import <XLFacility/XLFacilityMacros.h>

@interface QuickiOSLogServer ()

@property (nonatomic, strong) XLTelnetServerLogger *telnetServerLogger;
@property (nonatomic, strong) XLHTTPServerLogger *httpServerLogger;

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

+(void)stop
{
    [[QuickiOSLogServer sharedServer] stopServer];
}

-(XLTelnetServerLogger *)telnetServerLogger
{
    if (!_telnetServerLogger)
    {
        _telnetServerLogger = [[XLTelnetServerLogger alloc] init];
        _telnetServerLogger.format = @"<td>%d %P[%p:%r] %m%c</td>";
    }
    return _telnetServerLogger;
}

-(XLHTTPServerLogger *)httpServerLogger
{
    if (!_httpServerLogger)
    {
        _httpServerLogger = [[XLHTTPServerLogger alloc] initWithPort:8080];
        _httpServerLogger.format = @"<td>%d %P[%p:%r] %m%c</td>";
    }
    return _httpServerLogger;
}
- (void)startServer
{
    
    [XLSharedFacility addLogger:[QuickiOSLogServer sharedServer].telnetServerLogger];
    [XLSharedFacility addLogger:[QuickiOSLogServer sharedServer].httpServerLogger];
    XLSharedFacility.minLogLevel = kXLLogLevel_Info;
    XLOG_INFO(@"[QuickTraceiOSLogger] 您可以在 PC 控制台中使用 telnet %@ %lu 监听日志。", GCDTCPServerGetPrimaryIPAddress(false), (unsigned long)[QuickiOSLogServer sharedServer].telnetServerLogger.TCPServer.port);
    XLOG_INFO(@"[QuickTraceiOSLogger] 请在您的 PC 浏览器中打开 http://%@:%lu 浏览日志。", GCDTCPServerGetPrimaryIPAddress(false),(unsigned long)[QuickiOSLogServer sharedServer].httpServerLogger.TCPServer.port);
}

- (void)stopServer
{
    [XLSharedFacility removeAllLoggers];
    XLOG_INFO(@"[QuickTraceiOSLogger] 日志服务已停止。");
}

@end
