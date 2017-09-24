//
//  NSObject+ZJNetworkingMethods.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "NSObject+ZJNetworkingMethods.h"

@implementation NSObject (ZJNetworkingMethods)
-(id)ZJ_defaultValue:(id)defaultValue
{
    if (![defaultValue isKindOfClass:[self class]]){
        return defaultValue;
    }
    if ([self ZJ_isEmptyObject]){
        return defaultValue;
    }
    return self;
}
- (BOOL)ZJ_isEmptyObject
{
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if ([(NSString *)self length] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)self count] == 0) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if ([(NSDictionary *)self count] == 0) {
            return YES;
        }
    }
    
    return NO;

}
@end
