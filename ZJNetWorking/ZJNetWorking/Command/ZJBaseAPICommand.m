//
//  ZJBaseAPICommand.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ZJBaseAPICommand.h"

@interface ZJBaseAPICommand()<ZJAPIManagerCallBackDelegate>

@end
@implementation ZJBaseAPICommand
- (void)setApiManager:(ZJAPIBaseManager *)apiManager {
    _apiManager = apiManager;
    _apiManager.delegate = self;
}


- (void)excute {
    [self.apiManager loadData];
}


#pragma mark - ZJAPIManagerCallBackDelegate
- (void)managerCallAPIDidSuccess:(ZJAPIBaseManager *)manager {
    if (manager == self.apiManager && [self.delegate respondsToSelector:@selector(commandDidSuccess:)]) {
        [self.delegate commandDidSuccess:self];
        if (self.next) {
            [self.next excute];
        }
    }
}

- (void)managerCallAPIDidFlaied:(ZJAPIBaseManager *)manager {
    if (manager == self.apiManager && [self.delegate respondsToSelector:@selector(commandDidFailed:)]) {
        [self.delegate commandDidFailed:self];
    }
}
@end
