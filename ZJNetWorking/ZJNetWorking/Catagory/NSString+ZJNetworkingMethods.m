//
//  NSString+ZJNetworkingMethods.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "NSString+ZJNetworkingMethods.h"
#import "NSObject+ZJNetworkingMethods.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ZJNetworkingMethods)
- (NSString *)ZJ_md5
{
    NSData *inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
    CC_MD5([inputData bytes], (unsigned int)[inputData length], outputData);
    
    NSMutableString *hashChar = [NSMutableString string];
    int i = 0;
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
        [hashChar appendFormat:@"%02x", outputData[i]];
    
    return hashChar;
}
@end
