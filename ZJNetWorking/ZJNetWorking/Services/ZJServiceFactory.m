//
//  ZJServiceFactory.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ZJServiceFactory.h"

@interface ZJServiceFactory()

@property (nonatomic, strong) NSMutableDictionary *serviceStorage;
@end
@implementation ZJServiceFactory

#pragma mark - getters and setters
- (NSMutableDictionary *)serviceStorage
{
    if (_serviceStorage == nil) {
        _serviceStorage = [[NSMutableDictionary alloc] init];
    }
    return _serviceStorage;
}

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZJServiceFactory *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZJServiceFactory alloc] init];
    });
    return sharedInstance;
}
#pragma mark - public methods
- (ZJService<ZJServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier
{
    NSAssert(self.dataSource, @"必须提供dataSource绑定并实现servicesKindsOfServiceFactory方法，否则无法正常使用Service模块");
    
    if (self.serviceStorage[identifier] == nil) {
        self.serviceStorage[identifier] = [self newServiceWithIdentifier:identifier];
    }
    return self.serviceStorage[identifier];
}

#pragma mark - private methods
- (ZJService<ZJServiceProtocol> *)newServiceWithIdentifier:(NSString *)identifier
{
    NSAssert([self.dataSource respondsToSelector:@selector(servicesKindsOfServiceFactory)], @"请实现CTServiceFactoryDataSource的servicesKindsOfServiceFactory方法");
    
    if ([[self.dataSource servicesKindsOfServiceFactory] valueForKey:identifier]) {
        NSString *classStr = [[self.dataSource servicesKindsOfServiceFactory] valueForKey:identifier];
        id service = [[NSClassFromString(classStr) alloc]init];
        NSAssert(service, [NSString stringWithFormat:@"无法创建service，请检查servicesKindsOfServiceFactory提供的数据是否正确"],service);
        NSAssert([service conformsToProtocol:@protocol(ZJServiceProtocol)], @"你提供的Service没有遵循CTServiceProtocol");
        return service;
    }else {
        NSAssert(NO, @"servicesKindsOfServiceFactory中无法找不到相匹配identifier");
    }
    
    return nil;
}

@end
