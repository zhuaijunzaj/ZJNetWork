//
//  JddChainReqesutAgent.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/8/1.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddChainReqesutAgent.h"

@interface JddChainReqesutAgent ()
@property (nonatomic, strong) NSMutableArray <JddChainRequest*> *reqeustArray;
@end

@implementation JddChainReqesutAgent
+(instancetype)sharedInstance
{
    static JddChainReqesutAgent *agent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agent = [[self alloc] init];
    });
    return agent;
}
-(id)init
{
    self =  [super init];
    if (self){
        self.reqeustArray = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}
-(void)addChainRequest:(JddChainRequest *)request
{
    @synchronized (self) {
        [self.reqeustArray addObject:request];
    }
}
-(void)removeChainRequest:(JddChainRequest *)request
{
    @synchronized (self) {
        [self.reqeustArray removeObject:request];
    }
}
@end
