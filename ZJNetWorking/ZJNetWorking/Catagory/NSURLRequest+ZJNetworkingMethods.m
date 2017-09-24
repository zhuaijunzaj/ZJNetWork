//
//  NSURLRequest+ZJNetworkingMethods.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "NSURLRequest+ZJNetworkingMethods.h"
#import <objc/runtime.h>

static void *ZJNetworkingRequestParams;

@implementation NSURLRequest (ZJNetworkingMethods)

-(void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &ZJNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

-(NSDictionary*)requestParams
{
    return  objc_getAssociatedObject(self, &ZJNetworkingRequestParams);
}
@end
