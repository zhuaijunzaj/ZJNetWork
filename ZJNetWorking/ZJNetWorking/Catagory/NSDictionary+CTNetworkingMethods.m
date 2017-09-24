//
//  NSDictionary+CTNetworkingMethods.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "NSDictionary+CTNetworkingMethods.h"
#import "NSArray+CTNetworkingMethods.h"
@implementation NSDictionary (CTNetworkingMethods)

-(NSString*)ZJ_urlParamsStringSignature:(BOOL)isForSignature
{
    NSArray *sortedArray = [self ZJ_transformedUrlParamsArraySignature:isForSignature];
    return [sortedArray ZJ_paramsString];
}

-(NSString*)ZJ_jsonString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
-(NSArray*)ZJ_transformedUrlParamsArraySignature:(BOOL)isForSignature
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:1];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        if (!isForSignature) {
            obj = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)obj,  NULL,  (CFStringRef)@"!*'();:@&;=+$,/?%#[]",  kCFStringEncodingUTF8));
        }
        if ([obj length] > 0) {
            [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    NSArray *sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return sortedResult;

}
@end
