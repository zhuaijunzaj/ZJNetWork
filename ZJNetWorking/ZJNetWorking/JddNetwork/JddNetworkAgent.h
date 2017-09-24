//
//  JddNetworkAgent.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JddBaseRequest;

@interface JddNetworkAgent : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+(JddNetworkAgent*)sharedInstance;

- (void)addRequest:(JddBaseRequest *)request;
- (void)cancelRequest:(JddBaseRequest *)request;
- (void)cancelAllRequests;
- (NSString *)buildRequestUrl:(JddBaseRequest *)request;

@end
