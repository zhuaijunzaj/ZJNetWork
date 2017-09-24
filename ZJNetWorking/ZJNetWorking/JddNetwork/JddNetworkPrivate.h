//
//  JddNetworkPrivate.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JddRequest.h"
#import "JddBaseRequest.h"
#import "JddBatchRequest.h"
#import "JddChainRequest.h"
#import "JddNetworkAgent.h"
#import "JddNetworkConfigure.h"

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT void JddLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@class AFHTTPSessionManager;

@interface JddNetworkUtils : NSObject

+(BOOL)validateJSON:(id)json withValidator:(id)jsonValidator;
+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

+ (NSStringEncoding)stringEncodingWithRequest:(JddBaseRequest *)request;

+ (BOOL)validateResumeData:(NSData *)data;

@end

@interface JddRequest (Getter)
-(NSString*)cachedBasePath;
@end

@interface JddBaseRequest (Setter)
@property (nonatomic, strong, readwrite) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readwrite, nullable) NSData *responseData;
@property (nonatomic, strong, readwrite, nullable) id responseJSONObject;
@property (nonatomic, strong, readwrite, nullable) id responseObject;
@property (nonatomic, strong, readwrite, nullable) NSString *responseString;
@property (nonatomic, strong, readwrite, nullable) NSError *error;
@end


@interface JddNetworkAgent (Private)

- (AFHTTPSessionManager *)manager;
- (void)resetURLSessionManager;
- (void)resetURLSessionManagerWithConfiguration:(NSURLSessionConfiguration *)configuration;

- (NSString *)incompleteDownloadTempCacheFolder;

@end
NS_ASSUME_NONNULL_END;

