//
//  JddChainRequest.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddChainRequest.h"
#import "JddChainReqesutAgent.h"
#import "JddNetworkPrivate.h"
#import "JddBaseRequest.h"

@interface JddChainRequest ()<JddRequestDelegate>
@property (strong, nonatomic) NSMutableArray<JddBaseRequest *> *requestArray;
@property (strong, nonatomic) NSMutableArray<JddChainCallback> *requestCallbackArray;
@property (assign, nonatomic) NSUInteger nextRequestIndex;
@property (strong, nonatomic) JddChainCallback emptyCallback;
@end

@implementation JddChainRequest
-(id)init
{
    self = [super init];
    if (self){
        _nextRequestIndex = 0;
        _requestArray = [NSMutableArray arrayWithCapacity:1];
        _requestCallbackArray = [NSMutableArray arrayWithCapacity:1];
        _emptyCallback =^(JddChainRequest *chainRequest,JddBaseRequest *baseRequest){};
    }
    return  self;
}
-(void)start
{
    if (_nextRequestIndex > 0){
        JddLog(@"Error,Chain request has already begin");
        return;
    }
    if (_requestArray.count > 0){
        [self startNextRequest];
        [[JddChainReqesutAgent sharedInstance] addChainRequest:self];
    }else{
        JddLog(@"Error, Chain request array empty");
    }
}
-(void)stop
{
    [self cleatRequest];
    [[JddChainReqesutAgent sharedInstance] removeChainRequest:self];
}
-(void)addRequest:(JddBaseRequest *)request callback:(JddChainCallback)callback
{
    [_requestArray addObject:request];
    if (callback){
        [_requestCallbackArray addObject:callback];
    }else{
        [_requestCallbackArray addObject:self.emptyCallback];
    }
}
-(NSArray<JddBaseRequest*>*)requestArray
{
    return _requestArray;
}
-(BOOL)startNextRequest
{
    if (_nextRequestIndex < _requestArray.count){
        JddBaseRequest *reqeust = _requestArray[_nextRequestIndex];
        _nextRequestIndex ++;
        reqeust.delegate = self;
        [reqeust clearCompletionBlock];
        [reqeust start];
        return YES;
    }else{
        return NO;
    }
}

-(void)requestFinished:(JddBaseRequest *)request
{
    NSInteger currentRequestIndex = _nextRequestIndex;
    JddChainCallback callBack = _requestCallbackArray[currentRequestIndex];
    callBack(self,request);
    if (![self startNextRequest]){
        if (self.delegate){
            [self.delegate chainRequestFinished:self];
            [[JddChainReqesutAgent sharedInstance] addChainRequest:self];
        }
    }
}
-(void)requestFailed:(JddBaseRequest *)request
{
    if (self.delegate){
        [self.delegate chainReqeustFailed:self failedBaseRequest:request];
        [[JddChainReqesutAgent sharedInstance] removeChainRequest:self];
    }
}
-(void)cleatRequest
{
    NSInteger currentRequestIndex = _nextRequestIndex;
    if (currentRequestIndex < [_requestArray count]){
        JddBaseRequest *req = _requestArray[currentRequestIndex];
        [req stop];
    }
    [_requestArray removeAllObjects];
    [_requestCallbackArray removeAllObjects];
}
@end
