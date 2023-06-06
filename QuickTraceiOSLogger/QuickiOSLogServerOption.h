//
//  QuickiOSLogServerOption.h
//  QuickTraceiOSLogger
//
//  Created by pcjbird on 6/6/23.
//

#import <Foundation/Foundation.h>


@interface QuickiOSLogServerOption : NSObject

@property (nonatomic, assign) BOOL suspendInBackground;
@property (nonatomic, assign) NSInteger offlineDetectInterval;

+(QuickiOSLogServerOption*) sharedOption;

@end

