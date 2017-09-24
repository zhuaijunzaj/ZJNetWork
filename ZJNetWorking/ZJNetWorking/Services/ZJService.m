//
//  ZJService.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ZJService.h"
#import "NSObject+ZJNetworkingMethods.h"

@interface ZJService ()

@property (nonatomic, weak, readwrite) id<ZJServiceProtocol> child;

@end
@implementation ZJService

-(instancetype)init
{
    self = [super init];
    if (self){
        if ([self conformsToProtocol:@protocol(ZJServiceProtocol)]){
            self.child = (id<ZJServiceProtocol>)self;
        }
    }
    return self;
}
-(NSString*)urlGeneratingRuleByMethodName:(NSString *)method
{
    NSString *urlString = nil;
    if (![self.apiVersion ZJ_isEmptyObject]){
        urlString = [NSString stringWithFormat:@"%@/%@/%@", self.apiBaseUrl, self.apiVersion, method];
    }else{
        urlString = [NSString stringWithFormat:@"%@/%@", self.apiBaseUrl, method];
    }
    return urlString;
}

#pragma mark - getters and setters
- (NSString *)privateKey
{
    return self.child.isOnline ? self.child.onlinePrivateKey : self.child.offlinePrivateKey;
}

- (NSString *)publicKey
{
    return self.child.isOnline ? self.child.onlinePublicKey : self.child.offlinePublicKey;
}

- (NSString *)apiBaseUrl
{
    return self.child.isOnline ? self.child.onlineApiBaseUrl : self.child.offlineApiBaseUrl;
}

- (NSString *)apiVersion
{
    return self.child.isOnline ? self.child.onlineApiVersion : self.child.offlineApiVersion;
}

@end
