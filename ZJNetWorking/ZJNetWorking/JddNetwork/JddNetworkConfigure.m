//
//  JddNetworkConfigure.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddNetworkConfigure.h"
#import "JddBaseRequest.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@interface JddNetworkConfigure ()
{
    NSMutableArray <id<JddURLFilterProtocol>> *_urlFilters;
    NSMutableArray <id<JddCacheDirPathFilterProtocol>> *_cacheDirPathFilter;
}

@end
@implementation JddNetworkConfigure

+(JddNetworkConfigure*)sharedInstance
{
    static JddNetworkConfigure *configure = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configure = [[self alloc] init];
    });
    return configure;
}
-(id)init
{
    self = [super init];
    if (self){
        _baseURL = @"";
        _cdnURL = @"";
        _urlFilters = [NSMutableArray arrayWithCapacity:1];
        _cacheDirPathFilter = [NSMutableArray arrayWithCapacity:1];
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        _debugEnabled = NO;
    }
    return self;
}
-(void)addUrlFilter:(id<JddURLFilterProtocol>)filter
{
    [_urlFilters addObject:filter];
}
-(void)clearUrlFilter
{
    [_urlFilters removeAllObjects];
}
-(void)addCacheDirPathFilter:(id<JddCacheDirPathFilterProtocol>)filter
{
    [_cacheDirPathFilter addObject:filter];
}
-(void)clearCacheDirPathFilter
{
    [_cacheDirPathFilter removeAllObjects];
}
-(NSArray<id<JddURLFilterProtocol>> *)urlFilters
{
    return [_urlFilters copy];
}
-(NSArray<id<JddCacheDirPathFilterProtocol>>*)cacheDirPathFilters
{
    return [_cacheDirPathFilter copy];
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ baseURL: %@ } { cdnURL: %@ }", NSStringFromClass([self class]), self, self.baseURL, self.cdnURL];
}
@end
