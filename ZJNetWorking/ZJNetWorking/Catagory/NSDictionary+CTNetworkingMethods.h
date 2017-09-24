//
//  NSDictionary+CTNetworkingMethods.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CTNetworkingMethods)

-(NSString*)ZJ_urlParamsStringSignature:(BOOL)isForSignature;
-(NSString*)ZJ_jsonString;
-(NSArray*)ZJ_transformedUrlParamsArraySignature:(BOOL)isForSignature;
@end
