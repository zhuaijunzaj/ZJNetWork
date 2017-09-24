//
//  NSArray+CTNetworkingMethods.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "NSArray+CTNetworkingMethods.h"

@implementation NSArray (CTNetworkingMethods)

-(NSString*)ZJ_paramsString
{
    NSMutableString *paramString = [[NSMutableString alloc] init];
    NSArray *sortedParams = [self sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([paramString length] == 0){
            [paramString appendFormat:@"%@",obj];
        }else{
            [paramString appendFormat:@"&%@",obj];
        }
    }];
    return paramString;
}

-(NSString*)ZJ_jsonString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
