//
//  JddBaseRequest.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddBaseRequest.h"
#import "JddNetworkAgent.h"
#import "JddNetworkPrivate.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NSString *const JddRequestErrordomain = @"com.jddfun.reqeust.validation";

@interface JddBaseRequest()
@property (nonatomic, strong, readwrite) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readwrite) NSData *responseData;
@property (nonatomic, strong, readwrite) id responseJSONObject;
@property (nonatomic, strong, readwrite) id responseObject;
@property (nonatomic, strong, readwrite) NSString *responseString;
@property (nonatomic, strong, readwrite) NSError *error;
@end

@implementation JddBaseRequest

-(NSHTTPURLResponse*)response
{
    return (NSHTTPURLResponse*)self.requestTask.response;
}
-(NSInteger)responseStatusCode
{
    return self.response.statusCode;
}
-(NSDictionary*)responseHeaders
{
    return self.response.allHeaderFields;
}
-(NSURLRequest*)currentRequest
{
    return self.requestTask.currentRequest;
}
-(NSURLRequest*)originalRequest
{
    return self.requestTask.originalRequest;
}
-(BOOL)isCancelled
{
    if (!self.requestTask) return NO;
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}
-(BOOL)isExecuting
{
    if (!self.requestTask) return NO;
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}
-(void)setCompletionBlockWithSuccess:(JddRequestCompletionBlock)success failer:(JddRequestCompletionBlock)failer
{
    self.successBlock = success;
    self.failedBlock = failer;
}
-(void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failedBlock = nil;
}
-(void)start
{
    [[JddNetworkAgent sharedInstance] addRequest:self];
}
-(void)stop
{
    self.delegate = nil;
    [[JddNetworkAgent sharedInstance] cancelRequest:self];
    
}
-(void)startWithCompletionBlockWithSuccess:(JddRequestCompletionBlock)success failer:(JddRequestCompletionBlock)failer
{
    [self setCompletionBlockWithSuccess:success failer:failer];
    [self start];
}
-(void)requestCompletePreprocessor
{
    
}
-(void)requestCompleteFilter
{
    
}
-(void)requestFailedPrerocessor
{
    
}
-(void)reqeustFailedFilter
{
    
}
-(NSString*)reqeustURL
{
    return @"";
}
-(NSString*)cdnURL
{
    return @"";
}
-(NSString*)baseURL
{
    return @"";
}
-(NSTimeInterval)requestTimeoutInterval
{
    return 30.0;
}
-(id)requestArguments
{
    return nil;
}
-(id)cacheFileNameFilterForRequestArgument:(id)argument
{
    return argument;
}
-(JddRequestMethod)requestMethod
{
    return JddRequestMethodPost;
}
-(JddRequestSerializerType)requestSerializerType
{
    return JddRequestSerializerJSON;
}
-(JddResponseSerializerType)responseSerializerType
{
    return JddResponseSerializerJSON;
}
- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}

- (BOOL)useCDN {
    return NO;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

- (id)jsonValidator {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    return (statusCode >= 200 && statusCode <= 299);
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ URL: %@ } { method: %@ } { arguments: %@ }", NSStringFromClass([self class]), self, self.currentRequest.URL, self.currentRequest.HTTPMethod, self.requestArguments];
}
@end
