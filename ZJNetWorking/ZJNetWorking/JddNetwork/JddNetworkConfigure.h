//
//  JddNetworkConfigure.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JddBaseRequest;
@class AFSecurityPolicy;

@protocol JddURLFilterProtocol <NSObject>
-(NSString*)filterURL:(NSString*)originURL withRequest:(JddBaseRequest*)request;
@end
@protocol JddCacheDirPathFilterProtocol <NSObject>

-(NSString*)filterCacheDirPath:(NSString*)originPath withRequest:(JddBaseRequest*)request;


@end
@interface JddNetworkConfigure : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+(JddNetworkConfigure*)sharedInstance;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *cdnURL;
@property (nonatomic, strong, readonly) NSArray<id<JddURLFilterProtocol>> *urlFilters;
@property (nonatomic, strong, readonly) NSArray<id<JddCacheDirPathFilterProtocol>> *cacheDirPathFilters;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (nonatomic) BOOL debugEnabled;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

- (void)addUrlFilter:(id<JddURLFilterProtocol>)filter;

- (void)clearUrlFilter;
- (void)addCacheDirPathFilter:(id<JddCacheDirPathFilterProtocol>)filter;
- (void)clearCacheDirPathFilter;
@end
