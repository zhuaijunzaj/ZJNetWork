//
//  JddBatchReqeustAgent.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/8/1.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "JddBatchReqeustAgent.h"

@interface JddBatchReqeustAgent()
@property (nonatomic, strong) NSMutableArray <JddBatchRequest*> *reqeustArray;
@end
@implementation JddBatchReqeustAgent

+(instancetype)sharedInstance
{
    static JddBatchReqeustAgent *agent = nil;
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
-(void)addBatchRequest:(JddBatchRequest *)request
{
    @synchronized (self) {
        [self.reqeustArray addObject:request];
    }
}
-(void)removeBatchRequest:(JddBatchRequest *)request
{
    @synchronized (self) {
        [self.reqeustArray removeObject:request];
    }
}
@end
