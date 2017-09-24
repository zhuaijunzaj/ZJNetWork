//
//  JddNetworkPrivate.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/7/31.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddNetworkPrivate.h"
#import <CommonCrypto/CommonDigest.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFURLRequestSerialization.h>
#else
#import "AFURLRequestSerialization.h"
#endif

void JddLog(NSString *format, ...)
{
#ifdef DEBUG
    if (![JddNetworkConfigure sharedInstance].debugEnabled){
        return;
    }
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}

@implementation JddNetworkUtils

+(BOOL)validateJSON:(id)json withValidator:(id)jsonValidator
{
    if([json isKindOfClass:[NSDictionary class]] &&
       [jsonValidator isKindOfClass:[NSDictionary class]]){
        NSDictionary *dic = json;
        NSDictionary *validator = jsonValidator;
        
        BOOL result = YES;
        NSEnumerator *enumerator = [validator keyEnumerator];
        NSString *key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dic[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSArray class]]){
                result = [self validateJSON:value withValidator:validator];
                if (!result){
                    break;
                }
            }else{
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO){
                    result = NO;
                }
            }
        }
        return result;
    }else if ([json isKindOfClass:[NSArray class]] &&
              [jsonValidator isKindOfClass:[NSArray class]]){
        NSArray *validatorArray = (NSArray*)jsonValidator;
        if (validatorArray.count > 0){
            NSArray *array = (NSArray*)json;
            NSDictionary * validator = validatorArray[0];
            for (id item in array){
                BOOL result = [self validateJSON:item withValidator:validator];
                if (!result){
                    return NO;
                }
            }
        }
        return YES;
    }else if ([json isKindOfClass:jsonValidator]){
        return YES;
    }else{
        return NO;
    }
}
+(void)addDoNotBackupAttribute:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error){
        JddLog(@"error to set do not backup attribute,error = %@",error);
    }
}
+(NSString*)md5StringFromString:(NSString *)string
{
    NSParameterAssert(string != nil && [string length] > 0);
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}
+(NSString*)appVersionString
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
+(NSStringEncoding)stringEncodingWithRequest:(JddBaseRequest *)request
{
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    if (request.response.textEncodingName){
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)request.response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId){
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    return stringEncoding;
}
+(BOOL)validateResumeData:(NSData *)data
{
    if (!data || [data length] < 1) return NO;
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000)\
|| (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101100)
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
#endif
    return YES;
}
@end
















































