//
//  ZJLogger.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJService.h"
#import "ZJLoggerConfiguration.h"
#import "ZJURLResponse.h"

@interface ZJLogger : NSObject
@property (nonatomic, strong, readonly) ZJLoggerConfiguration *configParams;

+ (instancetype)sharedInstance;

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName service:(ZJService *)service requestParams:(id)requestParams httpMethod:(NSString *)httpMethod;
+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response responseString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error;
+ (void)logDebugInfoWithCachedResponse:(ZJURLResponse *)response methodName:(NSString *)methodName serviceIdentifier:(ZJService *)service;


- (void)logWithActionCode:(NSString *)actionCode params:(NSDictionary *)params;
@end
