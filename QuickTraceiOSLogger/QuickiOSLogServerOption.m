//
//  QuickiOSLogServerOption.m
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 6/6/23.
//

#import "QuickiOSLogServerOption.h"

@implementation QuickiOSLogServerOption

static QuickiOSLogServerOption *_sharedOption = nil;

+ (QuickiOSLogServerOption *) sharedOption
{
    static dispatch_once_t onceToken;
    dispatch_block_t block = ^{
        if(!_sharedOption)
        {
            _sharedOption = [[self class] new];
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
    return _sharedOption;
}

-(instancetype)init
{
    if(self = [super init])
    {
        _suspendInBackground = NO;
        _offlineDetectInterval = 30;
    }
    return self;
}


@end
