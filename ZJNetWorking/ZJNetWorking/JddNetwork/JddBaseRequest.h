//
//  JddBaseRequest.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const JddRequestErrordomain;

typedef NS_ENUM(NSInteger,JddRequestErrorCode){
    JddRequestErrorStatusCode = -8,
    JddReqeustErrorJSONFormat = -9,
};

typedef NS_ENUM(NSInteger,JddRequestMethod){
    JddRequestMethodGet = 0,
    JddRequestMethodPost,
};
typedef NS_ENUM(NSInteger,JddRequestSerializerType) {
    JddRequestSerializerHTTP = 0,
    JddRequestSerializerJSON,
};

typedef NS_ENUM(NSInteger,JddResponseSerializerType) {
    JddResponseSerializerHTTP = 0,
    JddResponseSerializerJSON,
    JddResponseSerializerXML,
};
typedef NS_ENUM(NSInteger,JddRequestPriority) {
    JddRequestPriorityLow = -4,
    JddRequestPriorityDefault = 0,
    JddRequestPriorityHigh = 4,
};

@protocol AFMultipartFormData;

typedef void (^AFConstructMultipartFormatDataBlock)(id<AFMultipartFormData> formData);
typedef void (^AFURLSessionTaskProgressBlock)(NSProgress *progress);

@class JddBaseRequest;

typedef void (^JddRequestCompletionBlock)(JddBaseRequest *request);

@protocol JddRequestDelegate <NSObject>

@optional
-(void)requestFinished:(JddBaseRequest*)request;
-(void)requestFailed:(JddBaseRequest*)request;
@end

@interface JddBaseRequest : NSObject
@property (nonatomic, strong, readonly) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readonly) NSURLRequest *currentRequest;
@property (nonatomic, strong, readonly) NSURLRequest *originalRequest;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;
@property (nonatomic, readonly) NSInteger responseStatusCode;
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, strong, readonly) NSData *responseData;
@property (nonatomic, strong, readonly) NSString *responseString;
@property (nonatomic, strong, readonly) id responseObject;
@property (nonatomic, strong, readonly) id responseJSONObject;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;
@property (nonatomic) NSInteger tag;
@property (nonatomic,strong, readonly) NSDictionary *userInfo;
@property (nonatomic, weak) id<JddRequestDelegate> delegate;
@property (nonatomic, copy, nullable) JddRequestCompletionBlock successBlock;
@property (nonatomic, copy, nullable) JddRequestCompletionBlock failedBlock;
@property (nonatomic, copy) AFConstructMultipartFormatDataBlock constructingBlock;
@property (nonatomic, assign) JddRequestPriority requestPriority;
@property (nonatomic, strong, readonly) NSString *resumableDownloadPath;
@property (nonatomic, strong, readonly) AFURLSessionTaskProgressBlock resumableDownloadProgressBlock;

-(void)setCompletionBlockWithSuccess:(JddRequestCompletionBlock)success
                              failer:(JddRequestCompletionBlock)failer;
-(void)clearCompletionBlock;
-(void)start;
-(void)stop;
-(void)startWithCompletionBlockWithSuccess:(JddRequestCompletionBlock)success
                                    failer:(JddRequestCompletionBlock)failer;

//override
-(void)requestCompletePreprocessor;
-(void)requestCompleteFilter;

-(void)requestFailedPrerocessor;
-(void)reqeustFailedFilter;

-(NSString*)baseURL;
-(NSString*)reqeustURL;//contain baseurl
-(NSString*)cdnURL;
-(NSTimeInterval)requestTimeoutInterval;
-(id)requestArguments;
- (id)cacheFileNameFilterForRequestArgument:(id)argument;
- (JddRequestMethod)requestMethod;
- (JddRequestSerializerType)requestSerializerType;
- (JddResponseSerializerType)responseSerializerType;
- (NSArray<NSString *> *)requestAuthorizationHeaderFieldArray;
- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;
- (NSURLRequest *)buildCustomUrlRequest;
- (BOOL)useCDN;
- (BOOL)allowsCellularAccess;
- (nullable id)jsonValidator;
- (BOOL)statusCodeValidator;

@end

NS_ASSUME_NONNULL_END








































