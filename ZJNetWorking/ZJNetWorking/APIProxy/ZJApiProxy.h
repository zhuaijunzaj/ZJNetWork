//
//  ZJApiProxy.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJURLResponse.h"

typedef void (^ZJCallback) (ZJURLResponse *response);

@interface ZJApiProxy : NSObject

+(instancetype)sharedInstance;

-(NSInteger)callGETWithParams:(NSDictionary*)params serviceIdentifier:(NSString*)serviceIdentifier methodName:(NSString*)methodName
                      success:(ZJCallback)success fail:(ZJCallback)fail;

-(NSInteger)callPOSTWithParams:(NSDictionary*)params serviceIdentifier:(NSString*)serviceIdentifier methodName:(NSString*)methodName
                      success:(ZJCallback)success fail:(ZJCallback)fail;

-(NSInteger)callPUTWithParams:(NSDictionary*)params serviceIdentifier:(NSString*)serviceIdentifier methodName:(NSString*)methodName
                      success:(ZJCallback)success fail:(ZJCallback)fail;

-(NSInteger)callDELETEWithParams:(NSDictionary*)params serviceIdentifier:(NSString*)serviceIdentifier methodName:(NSString*)methodName
                      success:(ZJCallback)success fail:(ZJCallback)fail;

-(NSNumber*)callApiWithRequest:(NSURLRequest*)request success:(ZJCallback)success fail:(ZJCallback)fail;
-(void)cancelRequestWithRequestId:(NSNumber*)requestId;
-(void)cancelRequestWithRequestIdList:(NSArray*)requestIdList;

@end
