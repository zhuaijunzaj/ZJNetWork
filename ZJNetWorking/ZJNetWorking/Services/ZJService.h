//
//  ZJService.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJURLResponse.h"

// 所有ZJService的派生类都要符合这个protocol
@protocol ZJServiceProtocol <NSObject>
@property (nonatomic, readonly) BOOL isOnline;

@property (nonatomic, copy, readonly) NSString *offlineApiBaseUrl;
@property (nonatomic, copy, readonly) NSString *onlineApiBaseUrl;

@property (nonatomic, copy, readonly) NSString *offlineApiVersion;
@property (nonatomic, copy, readonly) NSString *onlineApiVersion;

@property (nonatomic, copy, readonly) NSString *onlinePublicKey;
@property (nonatomic, copy, readonly) NSString *offlinePublicKey;

@property (nonatomic, copy, readonly) NSString *onlinePrivateKey;
@property (nonatomic, copy, readonly) NSString *offlinePrivateKey;

@optional

//为某些Service需要拼凑额外字段到URL处
- (NSDictionary *)extraParmas;

//为某些Service需要拼凑额外的HTTPToken，如accessToken
- (NSDictionary *)extraHttpHeadParmasWithMethodName:(NSString *)method;

- (NSString *)urlGeneratingRuleByMethodName:(NSString *)method;

//- (void)successedOnCallingAPI:(CTURLResponse *)response;

//提供拦截器集中处理Service错误问题，比如token失效要抛通知等
- (BOOL)shouldCallBackByFailedOnCallingAPI:(ZJURLResponse *)response;

@end
@interface ZJService : NSObject
@property (nonatomic, strong, readonly) NSString *publicKey;
@property (nonatomic, strong, readonly) NSString *privateKey;
@property (nonatomic, strong, readonly) NSString *apiBaseUrl;
@property (nonatomic, strong, readonly) NSString *apiVersion;

@property (nonatomic, weak, readonly) id<ZJServiceProtocol> child;

- (NSString *)urlGeneratingRuleByMethodName:(NSString *)method;

@end
