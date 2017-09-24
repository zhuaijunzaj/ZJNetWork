//
//  BaseApiManager.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/26.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJSessionManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef NS_ENUM(NSUInteger,APIManagerErrorType){
    APIManagerErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    APIManagerErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    APIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    APIManagerErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    APIManagerErrorTypeTimeout,       //请求超时。CTAPIProxy设置的是20秒超时，具体超时时间的设置请自己去看ZJAPIProxy的相关代码。
    APIManagerErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

typedef NS_ENUM(NSUInteger,APIManagerRequestType){
    APIManagerRequestTypeGet,
    APIManagerRequestTypePost,
};

@interface BaseApiManager : NSObject
@property (nonatomic, strong, readonly) id responseData;  // 返回数据
@property (nonatomic, strong, readonly) NSString *errorString;  // 错误信息
@property (nonatomic, strong) NSDictionary *params;             //请求参数
@property (nonatomic, strong) NSString *methodName;             //接口名称
@property (nonatomic, assign) APIManagerRequestType requestType;  //请求类型
@property (nonatomic, assign) APIManagerErrorType errorType;      //错误类型

-(RACSignal*)loadData;
-(RACSignal*)uploadUserInfo:(NSString*)userId;
@end
