//
//  NSMutableString+ZJNetworkingMethods.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "NSMutableString+ZJNetworkingMethods.h"
#import "NSObject+ZJNetworkingMethods.h"

@implementation NSMutableString (ZJNetworkingMethods)
- (void)ZJ_appendURLRequest:(NSURLRequest *)request
{
    [self appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
    [self appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [self appendFormat:@"\n\nHTTP Body:\n\t%@", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] ZJ_defaultValue:@"\t\t\t\tN/A"]];
}
@end
