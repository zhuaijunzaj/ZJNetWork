//
//  ZJSessionManager.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/26.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ZJSessionManager.h"

#define AppSystemVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define AppChannelId @"300001001"

@implementation ZJSessionManager
+(instancetype)sharedInstance
{
    static ZJSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [ZJSessionManager manager];
        manager.requestSerializer = [ZJSessionManager configureHttpHeader];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        NSMutableSet *acceptableContentTypes = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
//        [acceptableContentTypes addObject:@"text/plain"];
//        [acceptableContentTypes addObject:@"text/html"];
//        manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    });
    return manager;
}

+(AFJSONRequestSerializer*)configureHttpHeader
{
    AFJSONRequestSerializer *request = [AFJSONRequestSerializer serializer];
    [request setValue:AppSystemVersion forHTTPHeaderField:@"App-Version"];
    [request setValue:AppChannelId forHTTPHeaderField:@"App-Channel"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    return request;
}

@end
