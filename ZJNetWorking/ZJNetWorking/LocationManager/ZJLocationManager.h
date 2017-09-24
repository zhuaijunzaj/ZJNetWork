//
//  ZJLocationManager.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>



typedef NS_ENUM(NSUInteger, ZJLocationManagerLocationServiceStatus) {
    ZJLocationManagerLocationServiceStatusDefault,               //默认状态
    ZJLocationManagerLocationServiceStatusOK,                    //定位功能正常
    ZJLocationManagerLocationServiceStatusUnknownError,          //未知错误
    ZJLocationManagerLocationServiceStatusUnAvailable,           //定位功能关掉了
    ZJLocationManagerLocationServiceStatusNoAuthorization,       //定位功能打开，但是用户不允许使用定位
    ZJLocationManagerLocationServiceStatusNoNetwork,             //没有网络
    ZJLocationManagerLocationServiceStatusNotDetermined          //用户还没做出是否要允许应用使用定位功能的决定，第一次安装应用的时候会提示用户做出是否允许使用定位功能的决定
};

typedef NS_ENUM(NSUInteger, ZJLocationManagerLocationResult) {
    ZJLocationManagerLocationResultDefault,              //默认状态
    ZJLocationManagerLocationResultLocating,             //定位中
    ZJLocationManagerLocationResultSuccess,              //定位成功
    ZJLocationManagerLocationResultFail,                 //定位失败
    ZJLocationManagerLocationResultParamsError,          //调用API的参数错了
    ZJLocationManagerLocationResultTimeout,              //超时
    ZJLocationManagerLocationResultNoNetwork,            //没有网络
    ZJLocationManagerLocationResultNoContent             //API没返回数据或返回数据是错的
};


@interface ZJLocationManager : NSObject

@property (nonatomic, assign, readonly) ZJLocationManagerLocationResult locationResult;
@property (nonatomic, assign,readonly) ZJLocationManagerLocationServiceStatus locationStatus;
@property (nonatomic, copy, readonly) CLLocation *currentLocation;

+ (instancetype)sharedInstance;

- (void)startLocation;
- (void)stopLocation;
- (void)restartLocation;

@end
