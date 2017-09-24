//
//  JddBatchRequest.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddBatchRequest.h"
#import "JddNetworkPrivate.h"
#import "JddRequest.h"
#import "JddBatchReqeustAgent.h"
@interface JddBatchRequest()<JddRequestDelegate>

@property (nonatomic) NSInteger finishedCount;


@end

@implementation JddBatchRequest


-(id)initWithRequestArray:(NSArray<JddRequest *> *)requestArray
{
    self = [super init];
    if(self){
        _requestArray = requestArray;
        _finishedCount = 0;
        for (JddRequest *request in _requestArray){
            if ([request isKindOfClass:[JddRequest class]]){
                JddLog(@"Error,request itme must be JddReqeust isntance");
                return nil;
            }
        }
    }
    return self;
}
-(void)start
{
    if (_finishedCount > 0){
        JddLog(@"Error,Batch request has already begin");
        return;
    }
    _failedRequest = nil;
    [[JddBatchReqeustAgent sharedInstance] addBatchRequest:self];
    for (JddRequest *request in _requestArray){
        request.delegate = self;
        [request clearCompletionBlock];
        [request start];
    }
}
-(void)stop
{
    _delegate = nil;
    [self clearReqeust];
    [[JddBatchReqeustAgent sharedInstance] removeBatchRequest:self];
    
}
-(void)startWithCompletionBlockWithSuccess:(void (^)(JddBatchRequest * _Nonnull))success failure:(void (^)(JddBatchRequest * _Nonnull))failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}
-(void)setCompletionBlockWithSuccess:(void (^)(JddBatchRequest * _Nonnull))success failure:(void (^)(JddBatchRequest * _Nonnull))failure
{
    self.successComletionBlock = success;
    self.failedCompletionBlock = failure;
}
-(void)clearCompletionBlock
{
    self.successComletionBlock = nil;
    self.failedCompletionBlock = nil;
}
-(BOOL)isDataFromCache
{
    BOOL result = YES;
    for (JddRequest *req in _requestArray){
        if (!req.isDataFromCache){
            result = YES;
        }
    }
    return result;
}
-(void)dealloc
{
    [self clearReqeust];
}
-(void)requestFinished:(JddBaseRequest *)request
{
    _finishedCount ++;
    if (_finishedCount == _requestArray.count){
        if (self.delegate){
            [self.delegate batchRequestFinished:self];
        }
        if(self.successComletionBlock){
            self.successComletionBlock(self);
        }
        [self clearCompletionBlock];
        [[JddBatchReqeustAgent sharedInstance] removeBatchRequest:self];
    }
}
-(void)requestFailed:(JddBaseRequest *)request
{
    _failedRequest = (JddRequest*)request;
    for (JddRequest *req in _requestArray){
        [req stop];
    }
    
    if (self.delegate){
        [self.delegate batchRequestFailed:self];
    }
    if (self.failedCompletionBlock){
        self.failedCompletionBlock(self);
    }
    [self clearCompletionBlock];
    [[JddBatchReqeustAgent sharedInstance] removeBatchRequest:self];
}
-(void)clearReqeust
{
    for (JddRequest *req in _requestArray){
        [req stop];
    }
    [self clearCompletionBlock];
}
@end
