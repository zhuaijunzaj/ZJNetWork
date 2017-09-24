//
//  JddNetworkAgent.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddNetworkAgent.h"
#import "JddNetworkConfigure.h"
#import "JddNetworkPrivate.h"
#import <pthread.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

#define kJddNetworkIncompleteDownloadFolderName @"Incomplete"

@interface JddNetworkAgent()
{
    AFHTTPSessionManager *_manager;
    JddNetworkConfigure *_configure;
    AFJSONResponseSerializer *_jsonResponseSerializer;
    AFXMLParserResponseSerializer *_xmlResponseSerializer;
    
    NSMutableDictionary<NSNumber*,JddBaseRequest*> *_requestCord;
    
    dispatch_queue_t _processingQueue;
    pthread_mutex_t _lock;
    NSIndexSet *_allStatusCodes;
}

@end
@implementation JddNetworkAgent
+(JddNetworkAgent*)sharedInstance
{
    static JddNetworkAgent *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(id)init
{
    self = [super init];
    if (self){
        _configure = [JddNetworkConfigure sharedInstance];
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:_configure.sessionConfiguration];
        _requestCord = [NSMutableDictionary dictionaryWithCapacity:1];
        _processingQueue = dispatch_queue_create("com.jdd.network.processing", DISPATCH_QUEUE_CONCURRENT);
        _allStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        pthread_mutex_init(&_lock, NULL);
        _manager.securityPolicy = _configure.securityPolicy;
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.responseSerializer.acceptableStatusCodes = _allStatusCodes;
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.completionQueue = _processingQueue;
    }
    return self;
}
-(AFJSONResponseSerializer*)jsonResponseSerializer
{
    if (!_jsonResponseSerializer){
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _jsonResponseSerializer.acceptableStatusCodes = _allStatusCodes;
    }
    return _jsonResponseSerializer;
}
-(AFXMLParserResponseSerializer*)xmlResponseSerializer
{
    if (!_xmlResponseSerializer){
        _xmlResponseSerializer = [AFXMLParserResponseSerializer serializer];
        _xmlResponseSerializer.acceptableStatusCodes = _allStatusCodes;
    }
    return _xmlResponseSerializer;
}
-(NSString*)buildRequestUrl:(JddBaseRequest *)request
{
    NSParameterAssert(request!=nil);
    NSString *detailUrl = [request reqeustURL];
    NSURL *temp = [NSURL URLWithString:detailUrl];
    if (temp && temp.host && temp.scheme){
        return detailUrl;
    }
    NSArray *filters = [_configure urlFilters];
    for (id<JddURLFilterProtocol> f in filters){
        detailUrl = [f filterURL:detailUrl withRequest:request];
    }
    NSString *baseUrl;
    if ([request useCDN]){
        if ([[request cdnURL] length] > 0){
            baseUrl = [request cdnURL];
        }else{
            baseUrl = [_configure cdnURL];
        }
    }else{
        if ([[request cdnURL] length] > 0){
            baseUrl = [request cdnURL];
        }else{
            baseUrl = [_configure cdnURL];
        }
    }
    NSURL *url = [NSURL URLWithString:baseUrl];
    if(baseUrl.length > 0 && ![baseUrl hasSuffix:@"/"]){
        url = [url URLByAppendingPathComponent:@""];
    }
    return [NSURL URLWithString:detailUrl relativeToURL:url].absoluteString;
}
-(AFHTTPRequestSerializer*)requestSerializerForRequest:(JddBaseRequest*)request
{
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == JddRequestSerializerHTTP){
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }else if (request.requestSerializerType == JddRequestSerializerJSON){
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    
    NSArray<NSString*>*authorArray = [request requestAuthorizationHeaderFieldArray];
    if (authorArray != nil){
        [requestSerializer setAuthorizationHeaderFieldWithUsername:authorArray.firstObject password:authorArray.lastObject];
    }
    NSDictionary *headerFileds = [request requestHeaderFieldValueDictionary];
    if (headerFileds != nil){
        for (NSString *httpHeaderKey in headerFileds){
            NSString *value = headerFileds[httpHeaderKey];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderKey];
        }
    }
    return requestSerializer;
}

-(NSURLSessionTask*)sessionTaskForRequest:(JddBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error
{
    JddRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestArguments;
    AFConstructMultipartFormatDataBlock constructingBlock = [request constructingBlock];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:request];
    switch (method) {
        case JddRequestMethodGet:
            if (request.resumableDownloadPath){
                return [self downloadTaskWithDownloadPath:request.resumableDownloadPath requestSerializer:requestSerializer URLString:url parameters:param progress:request.resumableDownloadProgressBlock error:error];
            }else{
                return [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param error:error];
            }
            break;
        case JddRequestMethodPost:
            return [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param constructingBodyWithBlock:constructingBlock error:error];
            break;
        default:
            break;
    }
    return nil;
}
-(void)addRequest:(JddBaseRequest *)request
{
    NSParameterAssert(request != nil);
    NSError *__autoreleasing requestSerializerError = nil;
    NSURLRequest *customUrlRequest = [request buildCustomUrlRequest];
    if(customUrlRequest){
        __block NSURLSessionDataTask *dataTask = nil;
        __weak JddNetworkAgent *weakSelf = self;
        dataTask = [_manager dataTaskWithRequest:customUrlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [weakSelf handleRequestResult:dataTask responseObject:responseObject error:error];
        }];
        request.requestTask = dataTask;
    }else{
        request.requestTask = [self sessionTaskForRequest:request error:&requestSerializerError];
    }
    if (requestSerializerError){
        [self reqeustDidFailedWithRequest:request error:requestSerializerError];
        return;
    }
    NSAssert(request.requestTask != nil , @"requestTask should not be nil");
    if ([request.requestTask respondsToSelector:@selector(priority)]){
        switch (request.requestPriority) {
            case JddRequestPriorityLow:
                request.requestTask.priority = NSURLSessionTaskPriorityLow;
                break;
            case JddRequestPriorityHigh:
                request.requestTask.priority = NSURLSessionTaskPriorityHigh;
                break;
            case JddRequestPriorityDefault:
                request.requestTask.priority = NSURLSessionTaskPriorityDefault;
                break;
            default:
                break;
        }
    }
    JddLog(@"Add request:%@",NSStringFromClass([request class]));
    [self addRequestToRecord:request];
    [request.requestTask resume];
}
-(void)cancelRequest:(JddBaseRequest *)request
{
    NSParameterAssert(request != nil);
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
    
    [request clearCompletionBlock];
}
-(void)cancelAllRequests
{
    Lock();
    NSArray *allkeys = [_requestCord allKeys];
    Unlock();
    if (allkeys && allkeys.count > 0){
        NSArray *copiedKeys = [allkeys copy];
        for (NSNumber *key in copiedKeys){
            Lock();
            JddBaseRequest *request = _requestCord[key];
            Unlock();
            [request stop];
        }
    }
}

- (BOOL)validateResult:(JddBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error
{
    BOOL result = [request statusCodeValidator];
    if (!result){
        if (error){
            *error = [NSError errorWithDomain:JddRequestErrordomain code:JddRequestErrorStatusCode userInfo:@{NSLocalizedDescriptionKey:@"Invalid status code"}];
        }
        return result;
    }
    id json =[request responseJSONObject];
    id validator = [request jsonValidator];
    if (json && validator){
        result = [JddNetworkUtils validateJSON:json withValidator:validator];
        if (!result){
            *error = [NSError errorWithDomain:JddRequestErrordomain code:JddReqeustErrorJSONFormat userInfo:@{NSLocalizedDescriptionKey:@"Invalid json ofrmat"}];
            return result;
        }
    }
    return YES;
}
- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error
{
    Lock();
    JddBaseRequest *request = _requestCord[@(task.taskIdentifier)];
    Unlock();
    
    if (!request) return;
    
    JddLog(@"finished request: %@",NSStringFromClass([request class]));
    
    NSError * __autoreleasing serializationError = nil;
    NSError * __autoreleasing validationError = nil;
    
    NSError *reqeustError = nil;
    BOOL succeed = NO;
    
    request.responseObject = responseObject;
    if ([request.responseObject isKindOfClass:[NSData class]]){
        request.responseData = responseObject;
        request.responseString = [[NSString alloc] initWithData:request.responseData encoding:[JddNetworkUtils stringEncodingWithRequest:request]];
        
        switch (request.responseSerializerType) {
            case JddResponseSerializerHTTP:
                ;
                break;
            case JddResponseSerializerJSON:
                request.responseObject = [self->_jsonResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                request.responseJSONObject = request.responseObject;
                break;
            case JddResponseSerializerXML:
                request.responseObject = [self->_xmlResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&    serializationError];
            default:
                break;
        }
    }
    if (error){
        succeed = NO;
        reqeustError = error;
    }else if (serializationError){
        succeed = NO;
        reqeustError = serializationError;
    }else{
        succeed = [self validateResult:request error:&validationError];
        reqeustError =validationError;
    }
    if (succeed){
        [self requestDidSucceedWithRequest:request];
    }else{
        [self reqeustDidFailedWithRequest:request error:reqeustError];
    }
}
-(void)requestDidSucceedWithRequest:(JddBaseRequest*)request
{
    @autoreleasepool {
        [request requestCompletePreprocessor];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [request requestCompleteFilter];
        if (request.delegate != nil){
            [request.delegate requestFinished:request];
        }
        if(request.successBlock){
            request.successBlock(request);
        }
    });
}
-(void)reqeustDidFailedWithRequest:(JddBaseRequest*)request error:(NSError*)error
{
    request.error = error;
    JddLog(@"Request %@ failed,status code = %ld,error = %@",
           NSStringFromClass([request class]),(long)request.responseStatusCode,error.localizedDescription);
    
    NSData *incompleteDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    if (incompleteDownloadData){
        [incompleteDownloadData writeToURL:[self incompleteDownloadTempPathForDownloadPath:request.resumableDownloadPath] atomically:YES];
    }
    if ([request.responseObject isKindOfClass:[NSURL class]]){
        NSURL *url = request.responseObject;
        if (url.isFileURL && [[NSFileManager defaultManager] fileExistsAtPath:url.path]){
            request.responseData =[NSData dataWithContentsOfURL:url];
            request.responseString = [[NSString alloc] initWithData:request.responseData encoding:[JddNetworkUtils stringEncodingWithRequest:request]];
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        }
        request.responseObject = nil;
    }
    
    @autoreleasepool {
        [request requestFailedPrerocessor];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [request reqeustFailedFilter];
        if (request.delegate != nil){
            [request.delegate requestFailed:request];
        }
        if (request.failedBlock){
            request.failedBlock(request);
        }
    });
}

-(void)addRequestToRecord:(JddBaseRequest *)request
{
    Lock();
    _requestCord[@(request.requestTask.taskIdentifier)] = request;
    Unlock();
}
-(void)removeRequestFromRecord:(JddBaseRequest*)request
{
    Lock();
    [_requestCord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    JddLog(@"Request queue size = %zd", [_requestCord count]);
    Unlock();
}
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                           error:(NSError * _Nullable __autoreleasing *)error
{
    return [self dataTaskWithHTTPMethod:method requestSerializer:requestSerializer URLString:URLString parameters:parameters constructingBodyWithBlock:nil error:error];
}
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                       constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                           error:(NSError * _Nullable __autoreleasing *)error
{
    NSMutableURLRequest *request = nil;
    if (block){
        request  = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    }else{
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    }
    __block NSURLSessionDataTask *datatask = nil;
    __weak JddNetworkAgent *weakSelf = self;
    datatask = [_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [weakSelf handleRequestResult:datatask responseObject:responseObject error:error];
    }];
    return datatask;
}
- (NSURLSessionDownloadTask *)downloadTaskWithDownloadPath:(NSString *)downloadPath
                                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)URLString
                                                parameters:(id)parameters
                                                  progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                     error:(NSError * _Nullable __autoreleasing *)error
{
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:parameters error:error];
    NSString *dowloadTargetPath;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]){
        isDirectory = NO;
    }
    if (isDirectory){
        NSString *fileName = [urlRequest.URL lastPathComponent];
        dowloadTargetPath = [NSString pathWithComponents:@[downloadPath,fileName]];
    }else{
        dowloadTargetPath = downloadPath;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:dowloadTargetPath]){
        [[NSFileManager defaultManager] removeItemAtPath:dowloadTargetPath error:nil];
    }
    BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self incompleteDownloadTempPathForDownloadPath:downloadPath].path];
    NSData *data = [NSData dataWithContentsOfURL:[self incompleteDownloadTempPathForDownloadPath:downloadPath]];
    BOOL resumeDataIsValid = [JddNetworkUtils validateResumeData:data];
    BOOL canBeResumed = resumeDataIsValid && resumeDataFileExists;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    __block BOOL resumeSucced = NO;
    __weak JddNetworkAgent *weakSelf = self;
    if (canBeResumed){
        @try {
            downloadTask = [_manager downloadTaskWithResumeData:data progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL fileURLWithPath:dowloadTargetPath isDirectory:NO];
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                [weakSelf handleRequestResult:downloadTask responseObject:response error:error];
                
            }];
            resumeSucced = YES;
        } @catch (NSException *exception) {
            JddLog(@"Resume download failed,reason = %@",exception.reason);
            resumeSucced = NO;
        }
    }
    if (!resumeSucced){
        downloadTask = [_manager downloadTaskWithRequest:urlRequest progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:dowloadTargetPath isDirectory:NO];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [weakSelf handleRequestResult:downloadTask responseObject:response error:error];
        }];
    }
    return downloadTask;
}
- (NSString *)incompleteDownloadTempCacheFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    static NSString *cacheFolder ;
    if (!cacheFolder){
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:kJddNetworkIncompleteDownloadFolderName];
    }
    NSError *error = nil;
    if (![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]){
        JddLog(@"Failed to create cache directory at %@",cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}
- (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath {
    NSString *tempPath = nil;
    NSString *md5URLString = [JddNetworkUtils md5StringFromString:downloadPath];
    tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return [NSURL fileURLWithPath:tempPath];
}

-(AFHTTPSessionManager*)manager
{
    return _manager;
}
-(void)resetURLSessionManager
{
    _manager = [AFHTTPSessionManager manager];
}
- (void)resetURLSessionManagerWithConfiguration:(NSURLSessionConfiguration *)configuration {
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
}

@end











































