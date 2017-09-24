//
//  JddBatchRequest.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class JddBaseRequest;
@class JddBatchRequest;
@class JddRequest;
@protocol JddBatchRequestDelegate <NSObject>

-(void)batchRequestFinished:(JddBatchRequest*)request;
-(void)batchRequestFailed:(JddBatchRequest*)request;
@end

@interface JddBatchRequest : NSObject
@property (nonatomic, strong, readonly) NSArray<JddRequest*> * requestArray;
@property (nonatomic, weak) id<JddBatchRequestDelegate>delegate;
@property (nonatomic, copy, nullable) void (^successComletionBlock)(JddBatchRequest*);
@property (nonatomic, copy, nullable) void (^failedCompletionBlock)(JddBatchRequest*);
@property (nonatomic) NSInteger tag;

@property (nonatomic, strong, readonly) JddRequest *failedRequest;
- (instancetype )initWithRequestArray:(NSArray<JddRequest *> *)requestArray;
- (void)setCompletionBlockWithSuccess:(nullable void (^)(JddBatchRequest * batchRequest))success
                              failure:(nullable void (^)(JddBatchRequest * batchRequest))failure;
- (void)clearCompletionBlock;
- (void)start;
- (void)stop;
- (void)startWithCompletionBlockWithSuccess:(nullable void (^)(JddBatchRequest * batchRequest))success
                                    failure:(nullable void (^)(JddBatchRequest * batchRequest))failure;
- (BOOL)isDataFromCache;

@end

NS_ASSUME_NONNULL_END
