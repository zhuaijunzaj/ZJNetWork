//
//  BaseApiManager.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/26.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "BaseApiManager.h"

#define BaseUrl @"https://www.jddfun.com"

@interface BaseApiManager ()
@property (nonatomic, strong, readwrite) id responseData;
@property (nonatomic, strong, readwrite) NSString *errorString;
@end
@implementation BaseApiManager

-(id)init
{
    self = [super init];
    if (self){
        _requestType = APIManagerRequestTypeGet;
    }
    return self;
}

-(RACSignal*)loadData
{
    if (![self isReachable]){
        return [self getNoNetSignal];
    }
    __weak typeof(self) weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"%@/%@",BaseUrl,self.methodName];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSURLSessionDataTask *task = nil ;
        switch (strongSelf.requestType) {
            case APIManagerRequestTypeGet:
            {
               task =  [[ZJSessionManager sharedInstance] GET:url parameters:self.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   [strongSelf parseData:responseObject Subscriber:subscriber operation:task];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [strongSelf handleError:error Subscriber:subscriber];
                }];
            }
                break;
            case APIManagerRequestTypePost:
            {
                task = [[ZJSessionManager sharedInstance] POST:url parameters:self.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [strongSelf parseData:responseObject Subscriber:subscriber operation:task];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [strongSelf handleError:error Subscriber:subscriber];
                }];
            }
                break;
                
            default:
                break;
        }
//        return nil;
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
    return nil;
}

-(void)parseData:(id)responseData Subscriber:(id <RACSubscriber>)subscriber operation:(NSURLSessionDataTask *)task
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    NSString *errorId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"code"]];
    if ([errorId isEqualToString:@"200"]){
        [subscriber sendNext:dic[@"data"]];
        [subscriber sendCompleted];
    }else {
        NSString *msg = [dic objectForKey:@"message"];
        NSError *error = [NSError errorWithDomain:@"JddFun" code:[errorId integerValue] userInfo:@{@"msg":msg}];
        if ([errorId isEqualToString:@"401"]){
            
        }
        [subscriber sendError:error];
    }
}
-(void)handleError:(NSError *)error Subscriber:(id <RACSubscriber>)subscriber
{
    [subscriber sendError:error];
}
-(RACSignal *)getNoNetSignal {
    return [[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
        [subscriber sendError:error];
        return nil;
    }] setNameWithFormat:@"<%@: %p> -getNoNetSignal", self.class, self];
}
-(BOOL) isReachable
{
    BOOL isReachability;
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        isReachability = YES;
    } else {
        isReachability = [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
    return isReachability;
}

@end
