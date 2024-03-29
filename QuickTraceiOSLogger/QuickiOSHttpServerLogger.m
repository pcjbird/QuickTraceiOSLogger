//
//  QuickiOSHttpServerLogger.m
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 2018/3/22.
//  Copyright © 2018年 Zero Status. All rights reserved.
//
#if !__has_feature(objc_arc)
#error XLFacility requires ARC
#endif

#import "QuickiOSHttpServerLogger.h"
#if __has_include(<XLFacility/XLFunctions.h>)
#import <XLFacility/XLFunctions.h>
#else
#import "XLFunctions.h"
#endif
#if __has_include(<XLFacility/XLFacilityMacros.h>)
#import <XLFacility/XLFacilityMacros.h>
#else
#import "XLFacilityMacros.h"
#endif

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "QuickiOSLogServerOption.h"

#define APP_NAME ([[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] ? [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"]:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"])
#define APP_VERSION ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define APP_BUILD ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])
#define kDefaultMinRefreshDelay 500  // In milliseconds
#define kMaxLongPollDuration 30  // In seconds

@interface XLHTTPServerLogger(Private)
@property(nonatomic, readonly) NSDateFormatter* dateFormatterRFC822;
@end

@interface QuickiOSHttpServerLogger()
{
    dispatch_semaphore_t _pollingSemaphore;
}
@property (nonatomic, assign) NSTimeInterval refreshDelay;

@end

@interface QuickiOSHTTPServerConnection : GCDTCPServerConnection

@property (nonatomic, assign) NSTimeInterval refreshDelay;

@end

@implementation QuickiOSHTTPServerConnection {
    dispatch_semaphore_t _pollingSemaphore;
    NSMutableData* _headerData;
}

- (void)didReceiveLogRecord {
    if (_pollingSemaphore) {
        dispatch_semaphore_signal(_pollingSemaphore);
    }
}

- (BOOL)_writeHTTPResponseWithStatusCode:(NSInteger)statusCode image:(UIImage*)image {
    BOOL success = NO;
    CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode, NULL, kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Connection"), CFSTR("Close"));
    CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Server"), (__bridge CFStringRef)NSStringFromClass([self class]));
    CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Date"), (__bridge CFStringRef)[[(XLHTTPServerLogger*)self.logger dateFormatterRFC822] stringFromDate:[NSDate date]]);
    if ([image isKindOfClass:[UIImage class]]) {
        NSData* htmlData = UIImagePNGRepresentation(image);
        CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Type"), CFSTR("image/x-icon"));
        CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Length"), (__bridge CFStringRef)[NSString stringWithFormat:@"%lu", (unsigned long)htmlData.length]);
        CFHTTPMessageSetBody(response, (__bridge CFDataRef)htmlData);
    }
    NSData* data = CFBridgingRelease(CFHTTPMessageCopySerializedMessage(response));
    if (data) {
        [self writeDataAsynchronously:data
                           completion:^(BOOL ok) {
                               [self close];
                           }];
        success = YES;
    } else {
        XLOG_ERROR(@"Failed serializing HTTP response");
    }
    CFRelease(response);
    return success;
}

- (BOOL)_writeHTTPResponseWithStatusCode:(NSInteger)statusCode htmlBody:(NSString*)htmlBody {
    BOOL success = NO;
    CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode, NULL, kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Connection"), CFSTR("Close"));
    CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Server"), (__bridge CFStringRef)NSStringFromClass([self class]));
    CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Date"), (__bridge CFStringRef)[[(XLHTTPServerLogger*)self.logger dateFormatterRFC822] stringFromDate:[NSDate date]]);
    if (htmlBody) {
        NSData* htmlData = XLConvertNSStringToUTF8String(htmlBody);
        CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Type"), CFSTR("text/html; charset=utf-8"));
        CFHTTPMessageSetHeaderFieldValue(response, CFSTR("Content-Length"), (__bridge CFStringRef)[NSString stringWithFormat:@"%lu", (unsigned long)htmlData.length]);
        CFHTTPMessageSetBody(response, (__bridge CFDataRef)htmlData);
    }
    NSData* data = CFBridgingRelease(CFHTTPMessageCopySerializedMessage(response));
    if (data) {
        [self writeDataAsynchronously:data
                           completion:^(BOOL ok) {
                               [self close];
                           }];
        success = YES;
    } else {
        XLOG_ERROR(@"Failed serializing HTTP response");
    }
    CFRelease(response);
    return success;
}

- (void)_appendLogRecordsToString:(NSMutableString*)string afterAbsoluteTime:(CFAbsoluteTime)time {
    XLHTTPServerLogger* logger = (XLHTTPServerLogger*)self.logger;
    __block CFAbsoluteTime maxTime = time;
    [logger.databaseLogger enumerateRecordsAfterAbsoluteTime:time
                                                    backward:NO
                                                  maxRecords:0
                                                  usingBlock:^(int appVersion, XLLogRecord* record, BOOL* stop) {
                                                    const char* style = "color: dimgray;";
                                                    if (record.level == kXLLogLevel_Verbose){
                                                        style = "color: #000000;";
                                                    }
                                                    else if (record.level == kXLLogLevel_Debug) {
                                                        style = "color:#46C2F2;";
                                                    }
                                                    else if (record.level == kXLLogLevel_Info) {
                                                      style = "color: green;";
                                                    } else if (record.level == kXLLogLevel_Warning) {
                                                      style = "color: orange;";
                                                    } else if (record.level == kXLLogLevel_Error) {
                                                      style = "color: red;";
                                                    } else if (record.level >= kXLLogLevel_Exception) {
                                                      style = "color: red; font-weight: bold;";
                                                    }
                                                    NSString* formattedMessage = [logger formatRecord:record];
                                                    [string appendFormat:@"<tr style=\"%s\">%@</tr>", style, formattedMessage];
                                                    if (record.absoluteTime > maxTime) {
                                                      maxTime = record.absoluteTime;
                                                    }
                                                  }];
    [string appendFormat:@"<tr id=\"maxTime\" data-value=\"%f\"></tr>", maxTime];
}

- (BOOL)_processHTTPRequest:(CFHTTPMessageRef)request {
    BOOL success = NO;
    NSString* method = CFBridgingRelease(CFHTTPMessageCopyRequestMethod(request));
    if ([method isEqualToString:@"GET"]) {
        NSURL* url = CFBridgingRelease(CFHTTPMessageCopyRequestURL(request));
        NSString* path = url.path;
        NSString* query = url.query;
        
        if ([path isEqualToString:@"/"]) {
            NSMutableString* string = [[NSMutableString alloc] init];
            
            [string appendString:@"<!DOCTYPE html><html lang=\"en\">"];
            [string appendString:@"<head><meta charset=\"utf-8\">"];
            [string appendFormat:@"<title>%@ V%@ Build%@ 日志跟踪(%s[%i])</title>", APP_NAME, APP_VERSION, APP_BUILD, getprogname(), getpid()];
            [string appendString:@"<style>\
             body {\n\
             margin: 0px;\n\
             font-family: Courier, monospace;\n\
             font-size: 0.8em;\n\
             }\n\
             table {\n\
             width: 100%;\n\
             border-collapse: collapse;\n\
             }\n\
             tr {\n\
             vertical-align: top;\n\
             }\n\
             tr:nth-child(odd) {\n\
             background-color: #eeeeee;\n\
             }\n\
             td {\n\
             padding: 2px 10px;\n\
             }\n\
             #footer {\n\
             text-align: center;\n\
             margin: 20px 0px;\n\
             color: darkgray;\n\
             }\n\
             .error {\n\
             color: red;\n\
             font-weight: bold;\n\
             }\n\
             </style>"];
            [string appendFormat:@"<script type=\"text/javascript\">\n\
             var refreshDelay = %i;\n\
             var suspendInBackground = %i; \n\
             var footerElement = null;\n\
             function updateTimestamp() {\n\
             var now = new Date();\n\
             footerElement.innerHTML = \"Last updated on \" + now.toLocaleDateString() + \" \" + now.toLocaleTimeString();\n\
             }\n\
             function refresh(force = false) {\n\
             var timeElement = document.getElementById(\"maxTime\");\n\
             var maxTime = timeElement.getAttribute(\"data-value\");\n\
             timeElement.parentNode.removeChild(timeElement);\n\
             \n\
             var xmlhttp = new XMLHttpRequest();\n\
             xmlhttp.onreadystatechange = () => {\n\
             if (xmlhttp.readyState == 4) {\n\
             if (xmlhttp.status == 200) {\n\
             var contentElement = document.getElementById(\"content\");\n\
             contentElement.innerHTML = contentElement.innerHTML + xmlhttp.responseText;\n\
             updateTimestamp();\n\
             setTimeout(refresh, refreshDelay);\n\
             } else {\n\
             var contentElement = document.getElementById(\"content\");\n\
             var timeEle = \"<tr id=\" + \"\'\" + \"maxTime\" + \"\'\" +\" data-value=\" + maxTime + \"></tr>\"; \n\
             contentElement.innerHTML = contentElement.innerHTML + timeEle;\n\
             footerElement.innerHTML = \"<span class=\\\"error\\\">Connection failed! Reload page to try again.</span>\";\n\
             if (suspendInBackground > 0) { \n\
               setTimeout(refresh(true), refreshDelay);\n\
             }\n\
             }\n\
             }\n\
             }\n\
             xmlhttp.open(\"GET\", \"/log?after=\" + maxTime +\"&force=\" + force, true);\n\
             xmlhttp.send();\n\
             }\n\
             window.onload = function() {\n\
             footerElement = document.getElementById(\"footer\");\n\
             updateTimestamp();\n\
             setTimeout(refresh, refreshDelay);\n\
             }\n\
             </script>",
             kDefaultMinRefreshDelay, [QuickiOSLogServerOption sharedOption].suspendInBackground ? 1 : 0];
            [string appendString:@"</head>"];
            [string appendString:@"<body>"];
            [string appendFormat:@"<div style=\"padding-bottom: 9px;margin: 40px 0 20px;border-bottom: 1px solid #eee;text-align:center;\"><h1>%@ V%@ Build%@ 日志跟踪 (%s[%i])</h1></div>", APP_NAME, APP_VERSION, APP_BUILD, getprogname(), getpid()];
            [string appendString:@"<table><tbody id=\"content\">"];
            [self _appendLogRecordsToString:string afterAbsoluteTime:0.0];
            [string appendString:@"</tbody></table>"];
            [string appendString:@"<div id=\"footer\"></div>"];
            [string appendString:@"</body>"];
            [string appendString:@"</html>"];
            
            success = [self _writeHTTPResponseWithStatusCode:200 htmlBody:string];
        }
        else if([path isEqualToString:@"/favicon.ico"]){
            UIImage *icon = [UIImage imageNamed:@"AppIcon60x60"];
            if([icon isKindOfClass:[UIImage class]])
            {
               success = [self _writeHTTPResponseWithStatusCode:200 image:[[icon yy_imageByResizeToSize:CGSizeMake(32.0f, 32.0f)] yy_imageByRoundCornerRadius:4.0f]];
            }
            else
            {
                XLOG_WARNING(@"Unsupported path in HTTP request: %@", path);
                success = [self _writeHTTPResponseWithStatusCode:404 htmlBody:nil];
            }
        }
        else if ([path isEqualToString:@"/log"] && [query hasPrefix:@"after="]) {
            NSMutableString* string = [[NSMutableString alloc] init];
            CFAbsoluteTime time = 0;
            BOOL force = NO;
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
            NSArray *queryItems = components.queryItems;
            for (NSURLQueryItem *item in queryItems) {
                //NSLog(@"%@ = %@", item.name, item.value);
                if([item.name isEqualToString:@"after"])
                {
                    time = [item.value doubleValue];
                }
                else if([item.name isEqualToString:@"force"])
                {
                    force = [item.value boolValue];
                }
            }
            
            NSInteger seconds = force ? [QuickiOSLogServerOption sharedOption].offlineDetectInterval : kMaxLongPollDuration;
            
            _pollingSemaphore = dispatch_semaphore_create(0);
            dispatch_semaphore_wait(_pollingSemaphore, dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC));
            if (self.peer) {  // Check for race-condition if the connection was closed while waiting
                [self _appendLogRecordsToString:string afterAbsoluteTime:time];
                success = [self _writeHTTPResponseWithStatusCode:200 htmlBody:string];
            }
        }
        else {
            XLOG_WARNING(@"Unsupported path in HTTP request: %@", path);
            success = [self _writeHTTPResponseWithStatusCode:404 htmlBody:nil];
        }
        
    } else {
        XLOG_WARNING(@"Unsupported method in HTTP request: %@", method);
        success = [self _writeHTTPResponseWithStatusCode:405 htmlBody:nil];
    }
    return success;
}

- (void)_readHeaders {
    [self readDataAsynchronously:^(NSData* data) {
        if (data) {
            [self->_headerData appendData:data];
            NSRange range = [self->_headerData rangeOfData:[NSData dataWithBytes:"\r\n\r\n" length:4] options:0 range:NSMakeRange(0, self->_headerData.length)];
            if (range.location != NSNotFound) {
                BOOL success = NO;
                CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, true);
                CFHTTPMessageAppendBytes(message, data.bytes, data.length);
                if (CFHTTPMessageIsHeaderComplete(message)) {
                    success = [self _processHTTPRequest:message];
                } else {
                    XLOG_ERROR(@"Failed parsing HTTP request headers");
                }
                CFRelease(message);
                if (!success) {
                    [self close];
                }
                
            } else {
                [self _readHeaders];
            }
        } else {
            [self close];
        }
    }];
}

- (void)didOpen {
    [super didOpen];
    
    _headerData = [[NSMutableData alloc] init];
    [self _readHeaders];
}

- (void)didClose {
    [super didClose];
    
    if (_pollingSemaphore) {
        dispatch_semaphore_signal(_pollingSemaphore);
    }
}

#if !OS_OBJECT_USE_OBJC_RETAIN_RELEASE

- (void)dealloc {
    if (_pollingSemaphore) {
        dispatch_release(_pollingSemaphore);
    }
}

#endif

@end




@implementation QuickiOSHttpServerLogger


+ (Class)connectionClass {
    return [QuickiOSHTTPServerConnection class];
}

-(instancetype)init
{
    if(self = [super init])
    {
        [self initVariables];
    }
    return self;
}

-(instancetype)initWithPort:(NSUInteger)port
{
    if(self = [super initWithPort:port])
    {
        [self initVariables];
    }
    return self;
}

-(instancetype)initWithPort:(NSUInteger)port useDatabaseLogger:(BOOL)useDatabaseLogger
{
    if(self = [super initWithPort:port useDatabaseLogger:useDatabaseLogger])
    {
        [self initVariables];
    }
    return self;
}

-(void) initVariables
{
    
}

@end
