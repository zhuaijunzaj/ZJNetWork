//
//  ZJRequestGenerator.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ZJRequestGenerator.h"
#import "ZJSignatureGenerator.h"
#import "ZJServiceFactory.h"
#import "ZJCommonParamsGenerator.h"
#import "NSDictionary+CTNetworkingMethods.h"
#import "NSObject+ZJNetworkingMethods.h"
#import <AFNetworking/AFNetworking.h>
#import "ZJService.h"
#import "NSURLRequest+ZJNetworkingMethods.h"
#import "ZJNetWorkingConfigurationManager.h"
#import "ZJLogger.h"

@interface ZJRequestGenerator()
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@end
@implementation ZJRequestGenerator
#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZJRequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZJRequestGenerator alloc] init];
    });
    return sharedInstance;
}

- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams methodName:methodName requestWithMethod:@"GET"];
}

- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams methodName:methodName requestWithMethod:@"POST"];
}

- (NSURLRequest *)generatePutRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams methodName:methodName requestWithMethod:@"PUT"];
}

- (NSURLRequest *)generateDeleteRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    return [self generateRequestWithServiceIdentifier:serviceIdentifier requestParams:requestParams methodName:methodName requestWithMethod:@"DELETE"];
}

- (NSURLRequest *)generateRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName requestWithMethod:(NSString *)method {
    ZJService *service = [[ZJServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [service urlGeneratingRuleByMethodName:methodName];
    
    NSDictionary *totalRequestParams = [self totalRequestParamsByService:service requestParams:requestParams];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:method URLString:urlString parameters:totalRequestParams error:NULL];
    
    if (![method isEqualToString:@"GET"] && [ZJNetWorkingConfigurationManager sharedInstance].shouldSetParamsInHTTPBodyButGET) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:NULL];
    }
    
    if ([service.child respondsToSelector:@selector(extraHttpHeadParmasWithMethodName:)]) {
        NSDictionary *dict = [service.child extraHttpHeadParmasWithMethodName:methodName];
        if (dict) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [request setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    
    request.requestParams = totalRequestParams;
    return request;
}


#pragma mark - private method
//根据Service拼接额外参数
- (NSDictionary *)totalRequestParamsByService:(ZJService *)service requestParams:(NSDictionary *)requestParams {
    NSMutableDictionary *totalRequestParams = [NSMutableDictionary dictionaryWithDictionary:requestParams];
    
    if ([service.child respondsToSelector:@selector(extraParmas)]) {
        if ([service.child extraParmas]) {
            [[service.child extraParmas] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [totalRequestParams setObject:obj forKey:key];
            }];
        }
    }
    return [totalRequestParams copy];
}


#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = [ZJNetWorkingConfigurationManager sharedInstance].apiNetworkingTimeoutSeconds;
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}
@end
