//
//  JddChainRequest.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JddChainRequest;
@class JddBaseRequest;

@protocol JddChainRequestDelegate <NSObject>

@optional
-(void)chainRequestFinished:(JddChainRequest*)request;
-(void)chainReqeustFailed:(JddChainRequest*)chainreqeust failedBaseRequest:(JddBaseRequest*)request;

@end

typedef void (^JddChainCallback)(JddChainRequest* chainreqeust,JddBaseRequest *baserequest);
@interface JddChainRequest : NSObject
@property (nonatomic, weak, nullable) id<JddChainRequestDelegate> delegate;

- (NSArray<JddBaseRequest *> *)requestArray;
- (void)start;
- (void)stop;
- (void)addRequest:(JddBaseRequest *)request callback:(nullable JddChainCallback)callback;
@end
NS_ASSUME_NONNULL_END
