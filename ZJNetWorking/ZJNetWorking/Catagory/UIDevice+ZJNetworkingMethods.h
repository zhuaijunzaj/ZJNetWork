//
//  UIDevice+ZJNetworkingMethods.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIDevice (ZJNetworkingMethods)
- (NSString *) ZJ_macaddress;
- (NSString *) ZJ_macaddressMD5;
- (NSString *) ZJ_machineType;
- (NSString *) ZJ_ostype;//显示“ios6，ios5”，只显示大版本号
@end
