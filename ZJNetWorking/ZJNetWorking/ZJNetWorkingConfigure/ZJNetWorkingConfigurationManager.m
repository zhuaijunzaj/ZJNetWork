//
//  ZJNetWorkingConfigurationManager.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ZJNetWorkingConfigurationManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation ZJNetWorkingConfigurationManager

+(instancetype)sharedInstance
{
    static ZJNetWorkingConfigurationManager *sharedInstance =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZJNetWorkingConfigurationManager alloc] init];
        sharedInstance.shouldCache = YES;
        sharedInstance.serviceIsOnline = YES;
        sharedInstance.apiNetworkingTimeoutSeconds = 20.f;
        sharedInstance.cacheCountLimit = 1000;
        sharedInstance.cacheOutdateTimeSeconds = 300;
        sharedInstance.shouldSetParamsInHTTPBodyButGET = NO;
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    });
    return sharedInstance;
}

-(BOOL) isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}
@end
