//
//  JddRequest.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString * const JddRequestCacheErrorDomain;

typedef NS_ENUM(NSInteger,JddRequestCacheError) {
    JddRequestCacheErrorExpired = -1,
    JddRequestCacheErrorVersionMismatch = -2,
    JddRequestCacheErrorSensitiveDataMismatch = -3,
    JddRequestCacheErrorAppVersionMismatch = -4,
    JddRequestCacheErrorInvalidCacheTime = -5,
    JddRequestCacheErrorInvalidMetadata = -6,
    JddRequestCacheErrorInvalidCacheData = -7,

};
@interface JddRequest : JddBaseRequest
@property (nonatomic) BOOL ignoreCache;

-(BOOL)isDataFromCache;
- (BOOL)loadCacheWithError:(NSError **)error;
- (void)startWithoutCache;
- (void)saveResponseDataToCacheFile:(NSData *)data;
- (NSInteger)cacheTimeInSeconds;
- (long long)cacheVersion;
- (id)cacheSensitiveData;
- (BOOL)writeCacheAsynchronously;
@end
NS_ASSUME_NONNULL_END
