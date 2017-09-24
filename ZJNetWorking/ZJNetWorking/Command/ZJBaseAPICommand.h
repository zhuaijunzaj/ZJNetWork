//
//  ZJBaseAPICommand.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJAPIBaseManager.h"

@class ZJBaseAPICommand;

@protocol ZJAPICommandDelegate <NSObject>

@required

-(void)commandDidSuccess:(ZJBaseAPICommand*)command;
-(void)commandDidFailed:(ZJBaseAPICommand*)command;

@end

@protocol ZJAPICommand <NSObject>

//- (void)excute;

@end

@interface ZJBaseAPICommand : NSObject
@property (nonatomic, weak) id<ZJAPICommandDelegate> delegate;
@property (nonatomic, strong) ZJBaseAPICommand *next;
@property (nonatomic, strong) ZJAPIBaseManager *apiManager;
//@property (nonatomic, weak) id<ZJAPICommand> child;


- (void)excute;
@end
