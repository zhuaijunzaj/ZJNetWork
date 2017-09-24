//
//  JddRequest.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddRequest.h"
#import "JddNetworkConfigure.h"
#import "JddNetworkPrivate.h"

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_QoS_Available 1140.11
#else
#define NSFoundationVersionNumber_With_QoS_Available NSFoundationVersionNumber_iOS_8_0
#endif

NSString * const JddRequestCacheErrorDomain = @"com.jdd.request.caching";

static inline dispatch_queue_t jddrequest_cache_writing()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_attr_t attr = DISPATCH_QUEUE_SERIAL;
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_With_QoS_Available) {
            attr = dispatch_queue_attr_make_with_qos_class(attr, QOS_CLASS_BACKGROUND, 0);
        }
        queue = dispatch_queue_create("com.jdd.reqeust.writing", attr);
    });
    return queue;
}

@interface JddCacheMetaData:NSObject<NSSecureCoding>
@property (nonatomic, assign) long long version;
@property (nonatomic, strong) NSString *sensitiveDataString;
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *appVersionString;

-(void)saveData:(NSString*)path;
@end

@implementation JddCacheMetaData
+(BOOL)supportsSecureCoding
{
    return YES;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.version) forKey:NSStringFromSelector(@selector(version))];
    [aCoder encodeObject:self.sensitiveDataString forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    [aCoder encodeObject:@(self.stringEncoding) forKey:NSStringFromSelector(@selector(stringEncoding))];
    [aCoder encodeObject:self.creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:self.appVersionString forKey:NSStringFromSelector(@selector(appVersionString))];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (!self) {
        return nil;
    }
    self.version = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(version))] integerValue];
    self.sensitiveDataString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(sensitiveDataString))];
    self.stringEncoding = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(stringEncoding))] integerValue];
    self.creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
    self.appVersionString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(appVersionString))];
    
    return self;
}
-(void)saveData:(NSString*)path;
{
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}
@end
@interface JddRequest ()
@property (nonatomic, strong) NSData *cacheData;
@property (nonatomic, strong) NSString *cacheString;
@property (nonatomic, strong) id cacheJSON;
@property (nonatomic, strong) NSXMLParser *cacheXML;

@property (nonatomic, strong) JddCacheMetaData *cacheMetadata;
@property (nonatomic, assign) BOOL dataFromCache;
@end

@implementation JddRequest

-(void)start
{
    if (self.ignoreCache){
        [self startWithoutCache];
        return;
    }
    if (self.resumableDownloadPath){
        [self startWithoutCache];
        return;
    }
    if (![self loadCacheWithError:nil]){
        [self startWithoutCache];
        return;
    }
    _dataFromCache = YES;
    __weak JddRequest *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf requestCompletePreprocessor];
        [weakSelf requestCompleteFilter];
        if (weakSelf.delegate){
            [weakSelf.delegate requestFinished:weakSelf];
        }
        if (weakSelf.successBlock){
            weakSelf.successBlock(weakSelf);
        }
        [weakSelf clearCompletionBlock];
    });
}
-(void)startWithoutCache
{
    [self clearCacheVariables];
    [super start];
}

-(void)requestCompletePreprocessor
{
    [super requestCompletePreprocessor];
    if (self.writeCacheAsynchronously){
        __weak JddRequest *wealSelf = self;
        dispatch_async(jddrequest_cache_writing(), ^{
            [wealSelf saveResponseDataToCacheFile:[super responseData]];
        });
    }else{
        [self saveResponseDataToCacheFile:[super responseData]];
    }
}
-(NSInteger)cacheTimeInSeconds
{
    return -1;
}
-(long long)cacheVersion
{
    return 0;
}
-(id)cacheSensitiveData
{
    return nil;
}
-(BOOL)writeCacheAsynchronously
{
    return YES;
}

-(BOOL)isDataFromCache
{
    return _dataFromCache;
}
-(NSData*)responseData
{
    if (_cacheData){
        return _cacheData;
    }
    return [super responseData];
}
-(NSString*)responseString
{
    if (_cacheString){
        return _cacheString;
    }
    return [super responseString];
}
-(id)responseJSONObject
{
    if (_cacheJSON){
        return _cacheJSON;
    }
    return [super responseJSONObject];
}
-(id)responseObject
{
    if (_cacheJSON){
        return _cacheJSON;
    }
    if (_cacheXML)
    {
        return _cacheXML;
    }
    if (_cacheData){
        return _cacheData;
    }
    return [super responseObject];
}
-(BOOL)loadCacheWithError:(NSError * _Nullable __autoreleasing *)error
{
    if ([self cacheTimeInSeconds] < 0){
        if (error){
            *error =[NSError errorWithDomain:JddRequestCacheErrorDomain code:JddRequestCacheErrorInvalidCacheTime userInfo:@{NSLocalizedDescriptionKey:@"Invalid cache time"}];
        }
        return NO;
    }
    if (![self loadCacheMetadata]){
        if (error){
            *error = [NSError errorWithDomain:JddRequestCacheErrorDomain code:JddRequestCacheErrorInvalidMetadata userInfo:@{NSLocalizedDescriptionKey:@"Invalid metadata"}];
        }
        return NO;
    }
    if (![self validateCacheWithError:error]) return NO;
    
    if (![self loadCacheData]){
        if (error){
            *error = [NSError errorWithDomain:JddRequestCacheErrorDomain code:JddRequestCacheErrorInvalidCacheData userInfo:@{NSLocalizedDescriptionKey:@"Invalid cache data"}];
        }
        return NO;
        
    }
    return YES;
    
}
-(BOOL)validateCacheWithError:(NSError**)error
{
    NSDate *creationDate = self.cacheMetadata.creationDate;
    NSTimeInterval duration = -[creationDate timeIntervalSinceNow];
    if (duration < 0 || duration > [self cacheTimeInSeconds]){
        if (error){
            *error =[NSError errorWithDomain:JddRequestCacheErrorDomain code:JddRequestCacheErrorExpired userInfo:@{NSLocalizedDescriptionKey:@"Cache Expired"}];
            return NO;
        }
    }
    long long cacheVersion = self.cacheMetadata.version;
    if (cacheVersion != [self cacheVersion]){
        if (error){
            *error = [NSError errorWithDomain:JddRequestCacheErrorDomain code:JddRequestCacheErrorVersionMismatch userInfo:@{NSLocalizedDescriptionKey:@"Cache version mismatch"}];
            return NO;
        }
    }
    NSString *sensitiveDataString = self.cacheMetadata.sensitiveDataString;
    NSString *currentSensitiveString = ((NSObject*)[self cacheSensitiveData]).description;
    if (sensitiveDataString || currentSensitiveString){
        if (sensitiveDataString.length != currentSensitiveString.length || ![sensitiveDataString isEqualToString:currentSensitiveString]){
            if (error){
                *error =[NSError errorWithDomain:JddRequestCacheErrorDomain code:JddRequestCacheErrorSensitiveDataMismatch userInfo:@{NSLocalizedDescriptionKey:@"Cache sensitive data mismatch"}];
            }
            return NO;
        }
    }
    NSString *appVersionString = self.cacheMetadata.appVersionString;
    NSString *currentAppVersionString = [JddNetworkUtils appVersionString];
    if (appVersionString || currentAppVersionString) {
        if (appVersionString.length != currentAppVersionString.length || ![appVersionString isEqualToString:currentAppVersionString]) {
            if (error) {
                *error = [NSError errorWithDomain:JddRequestCacheErrorDomain code:JddRequestCacheErrorAppVersionMismatch userInfo:@{ NSLocalizedDescriptionKey:@"App version mismatch"}];
            }
            return NO;
        }
    }
    return YES;
}
-(BOOL)loadCacheMetadata
{
    NSString *path = [self cacheMetadataFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]){
        @try {
            _cacheMetadata = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            return YES;
        } @catch (NSException *exception) {
            JddLog(@"Load Metadata faield,reason = %@",exception.reason);
            return NO;
        }
    }
    return NO;
}
-(BOOL)loadCacheData
{
    NSString *path = [self cacheFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:path isDirectory:nil]){
        NSData *data = [NSData dataWithContentsOfFile:path];
        _cacheData = data;
        _cacheString = [[NSString alloc] initWithData:_cacheData encoding:self.cacheMetadata.stringEncoding];
        switch (self.responseSerializerType) {
            case JddResponseSerializerHTTP:
                return YES;
                break;
            case JddResponseSerializerJSON:
                _cacheJSON = [NSJSONSerialization JSONObjectWithData:_cacheData options:(NSJSONReadingOptions)0 error:&error];
                return error == nil;
            case JddResponseSerializerXML:
                _cacheXML = [[NSXMLParser alloc] initWithData:_cacheData];
                return YES;
            default:
                break;
        }
    }
    return NO;
}
-(void)saveResponseDataToCacheFile:(NSData *)data
{
    if([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]){
        if (data != nil){
            @try {
                [data writeToFile:[self cacheFilePath] atomically:YES];
                JddCacheMetaData *metadata = [[JddCacheMetaData alloc] init];
                metadata.version = [self cacheVersion];
                metadata.sensitiveDataString = ((NSObject*)[self cacheSensitiveData]).description;
                metadata.stringEncoding = [JddNetworkUtils stringEncodingWithRequest:self];
                metadata.creationDate = [NSDate date];
                metadata.appVersionString = [JddNetworkUtils appVersionString];
                [metadata saveData:[self cacheMetadataFilePath]];
            } @catch (NSException *exception) {
                JddLog(@"Save cache failed,reason = %@",exception.reason);
            }
        }
    }
}
-(void)clearCacheVariables
{
    _cacheXML = nil;
    _cacheData = nil;
    _cacheJSON = nil;
    _cacheString = nil;
    _cacheMetadata = nil;
    _dataFromCache = NO;
}
-(void)createDirectoryIfNeeded:(NSString*)path
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManger fileExistsAtPath:path isDirectory:&isDir]){
        [self createBaseDirectoryAtPath:path];
    }else{
        if (!isDir){
            NSError *error = nil;
            [fileManger removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}
-(void)createBaseDirectoryAtPath:(NSString*)path
{
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (error){
        JddLog(@"create cache directory failed,error = %@",error);
    }else{
        [JddNetworkUtils addDoNotBackupAttribute:path];
    }
}
-(NSString*)cachedBasePath
{
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingString:@"lazyRequestCache"];
    
    NSArray<id<JddCacheDirPathFilterProtocol>> *filters = [[JddNetworkConfigure sharedInstance] cacheDirPathFilters];
    for (id<JddCacheDirPathFilterProtocol> f in filters){
        path = [f filterCacheDirPath:path withRequest:self];
    }
    [self createDirectoryIfNeeded:path];
    return path;
}
-(NSString*)cacheFileName
{
    NSString *requestUrl = [self reqeustURL];
    NSString *baseUrl = [[JddNetworkConfigure sharedInstance] baseURL];
    id argument = [self cacheFileNameFilterForRequestArgument:[self requestArguments]];
    NSString *reuqestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@",(long)[self requestMethod],baseUrl,requestUrl,argument];
    NSString *cacheFileName = [JddNetworkUtils md5StringFromString:reuqestInfo];
    return cacheFileName;
}
-(NSString*)cacheFilePath
{
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cachedBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}
-(NSString*)cacheMetadataFilePath
{
    NSString *cacheMetadataFileName = [NSString stringWithFormat:@"%@.metadata",[self cacheFileName]];
    NSString *path = [self cachedBasePath];
    path = [path stringByAppendingPathComponent:cacheMetadataFileName];
    return path;
}
@end























































