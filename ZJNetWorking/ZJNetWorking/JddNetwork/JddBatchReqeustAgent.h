//
//  JddBatchReqeustAgent.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/8/1.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JddBatchRequest.h"

@interface JddBatchReqeustAgent : NSObject

+(instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (void)addBatchRequest:(JddBatchRequest *)request;
- (void)removeBatchRequest:(JddBatchRequest *)request;
@end
