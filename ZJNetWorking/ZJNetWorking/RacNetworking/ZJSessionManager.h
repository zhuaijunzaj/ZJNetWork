//
//  ZJSessionManager.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/26.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface ZJSessionManager : AFHTTPSessionManager

+(instancetype)sharedInstance;

@end
