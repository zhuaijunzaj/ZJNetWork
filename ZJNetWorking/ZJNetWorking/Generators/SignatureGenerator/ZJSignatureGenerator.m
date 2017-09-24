//
//  ZJSignatureGenerator.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ZJSignatureGenerator.h"
#import "ZJCommonParamsGenerator.h"
#import "NSDictionary+CTNetworkingMethods.h"
#import "NSArray+CTNetworkingMethods.h"
#import "NSString+ZJNetworkingMethods.h"

@implementation ZJSignatureGenerator

#pragma mark - public methods
+ (NSString *)signGetWithSigParams:(NSDictionary *)allParams methodName:(NSString *)methodName apiVersion:(NSString *)apiVersion privateKey:(NSString *)privateKey publicKey:(NSString *)publicKey
{
    NSString *sigString = [allParams ZJ_urlParamsStringSignature:YES];
    return [[NSString stringWithFormat:@"%@%@", sigString, privateKey] ZJ_md5];
}

+ (NSString *)signRestfulGetWithAllParams:(NSDictionary *)allParams methodName:(NSString *)methodName apiVersion:(NSString *)apiVersion privateKey:(NSString *)privateKey
{
    NSString *part1 = [NSString stringWithFormat:@"%@/%@", apiVersion, methodName];
    NSString *part2 = [allParams ZJ_urlParamsStringSignature:YES];
    NSString *part3 = privateKey;
    
    NSString *beforeSign = [NSString stringWithFormat:@"%@%@%@", part1, part2, part3];
    return [beforeSign ZJ_md5];
}

+ (NSString *)signPostWithApiParams:(NSDictionary *)apiParams privateKey:(NSString *)privateKey publicKey:(NSString *)publicKey
{
    NSMutableDictionary *sigParams = [NSMutableDictionary dictionaryWithDictionary:apiParams];
    sigParams[@"api_key"] = publicKey;
    NSString *sigString = [sigParams ZJ_urlParamsStringSignature:YES];
    return [[NSString stringWithFormat:@"%@%@", sigString, privateKey] ZJ_md5];
}

+ (NSString *)signRestfulPOSTWithApiParams:(id)apiParams commonParams:(NSDictionary *)commonParams methodName:(NSString *)methodName apiVersion:(NSString *)apiVersion privateKey:(NSString *)privateKey
{
    NSString *part1 = [NSString stringWithFormat:@"%@/%@", apiVersion, methodName];
    NSString *part2 = [commonParams ZJ_urlParamsStringSignature:YES];
    NSString *part3 = nil;
    if ([apiParams isKindOfClass:[NSDictionary class]]) {
        part3 = [(NSDictionary *)apiParams ZJ_jsonString];
    } else if ([apiParams isKindOfClass:[NSArray class]]) {
        part3 = [(NSArray *)apiParams ZJ_jsonString];
    } else {
        return @"";
    }
    
    NSString *part4 = privateKey;
    
    NSString *beforeSign = [NSString stringWithFormat:@"%@%@%@%@", part1, part2, part3, part4];
    
    return [beforeSign ZJ_md5];
}

@end
