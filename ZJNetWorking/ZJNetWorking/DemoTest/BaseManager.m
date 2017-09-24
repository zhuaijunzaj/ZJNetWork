//
//  BaseManager.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "BaseManager.h"

@interface BaseManager()<ZJAPIManagerValidator>

@end
@implementation BaseManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.validator = self;
    }
    return self;
}

- (NSString *)methodName
{
    return @"/api_app/api/index/list";
}

- (NSString *)serviceType
{
    return @"homelist";
}
- (ZJAPIManagerRequestType)requestType
{
    return ZJAPIManagerRequestTypePost;
}

- (BOOL)shouldCache
{
    return YES;
}
- (NSDictionary *)reformParams:(NSDictionary *)params
{
    NSMutableDictionary *resultParams = [[NSMutableDictionary alloc] init];
//    resultParams[@"key"] = [[CTServiceFactory sharedInstance] serviceWithIdentifier:kCTServiceGDMapV3].publicKey;
//    resultParams[@"location"] = [NSString stringWithFormat:@"%@,%@", params[kTestAPIManagerParamsKeyLongitude], params[kTestAPIManagerParamsKeyLatitude]];
//    resultParams[@"output"] = @"json";
    return resultParams;
}
#pragma mark - ZJAPIManagerValidator
- (BOOL)manager:(ZJAPIBaseManager *)manager isCorrectWithParamsData:(NSDictionary *)data
{
    return YES;
}

- (BOOL)manager:(ZJAPIBaseManager *)manager isCorrectWithCallBackData:(NSDictionary *)data
{
    if ([data[@"status"] isEqualToString:@"0"]) {
        return YES;
    }
    
    return YES;
}

@end
