//
//  ZJServiceFactory.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJService.h"

@protocol ZJServiceFactoryDataSource <NSObject>

-(NSDictionary<NSString*,NSString*> *)servicesKindsOfServiceFactory;

@end
@interface ZJServiceFactory : NSObject

@property (nonatomic, weak) id<ZJServiceFactoryDataSource> dataSource;

+ (instancetype)sharedInstance;
- (ZJService<ZJServiceProtocol> *)serviceWithIdentifier:(NSString *)identifier;
@end
