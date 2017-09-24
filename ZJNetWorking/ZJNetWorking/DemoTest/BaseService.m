//
//  BaseService.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "BaseService.h"
#import "ZJNetWorkingConfigurationManager.h"
@implementation BaseService
- (BOOL)isOnline
{
    return [ZJNetWorkingConfigurationManager sharedInstance].serviceIsOnline;
}

- (NSString *)offlineApiBaseUrl
{
    return @"http://192.168.101.241";
}

- (NSString *)onlineApiBaseUrl
{
    return @"https://www.jddfun.com";
}

- (NSString *)offlineApiVersion
{
    return @"";
}

- (NSString *)onlineApiVersion
{
    return @"";
}

- (NSString *)onlinePublicKey
{
    return @"";
}

- (NSString *)offlinePublicKey
{
    return @"";
}

- (NSString *)onlinePrivateKey
{
    return @"";
}

- (NSString *)offlinePrivateKey
{
    return @"";
}


//为某些Service需要拼凑额外的HTTPToken，如accessToken
- (NSDictionary *)extraHttpHeadParmasWithMethodName:(NSString *)method {
    return @{@"App-Version": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
             @"App-Channel":@"300001001",
             @"Content-Type":@"application/json;charset=UTF-8"};
}

- (BOOL)shouldCallBackByFailedOnCallingAPI:(ZJURLResponse *)response{
    BOOL result = YES;
    
    return result;
}
@end
