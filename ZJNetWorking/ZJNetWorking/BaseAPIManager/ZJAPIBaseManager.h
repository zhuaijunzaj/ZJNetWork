//
//  ZJAPIBaseManager.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJURLResponse.h"

@class  ZJAPIBaseManager;

// 在调用成功之后的params字典里面，用这个key可以取出requestID
static NSString * const kZJAPIBaseManagerRequestID = @"kZJAPIBaseManagerRequestID";

/*
 总述：
 这个base manager是用于给外部访问API的时候做的一个基类。任何继承这个基类的manager都要添加两个getter方法：
 
 - (NSString *)methodName
 {
 return @"community.searchMap";
 }
 
 - (RTServiceType)serviceType
 {
 return RTcasatwyServiceID;
 }
 
 外界在使用manager的时候，如果需要调api，只要调用loadData即可。manager会去找paramSource来获得调用api的参数。调用成功或失败，则会调用delegate的回调函数。
 
 继承的子类manager可以重载basemanager提供的一些方法，来实现一些扩展功能。具体的可以看m文件里面对应方法的注释。
 */

//api回调
@protocol ZJAPIManagerCallBackDelegate <NSObject>

@required
-(void)managerCallAPIDidSuccess:(ZJAPIBaseManager*)manger;
-(void)managerCallAPIDidFlaied:(ZJAPIBaseManager*)manager;

@end

//负责重新组装API数据的对象
@protocol ZJAPIManagerDataReformer <NSObject>

@required
-(id)manager:(ZJAPIBaseManager*)manager reformData:(NSDictionary*)data;

@end

//验证器，用于验证API的返回或者调用API的参数是否正确
@protocol ZJAPIManagerValidator <NSObject>

-(BOOL)manager:(ZJAPIBaseManager*)manager isCorrectWithCallBackData:(NSDictionary *)data;

@end

//让manager能够获取调用API所需要的数据
@protocol ZJAPIManagerParamSource <NSObject>

@required
-(NSDictionary*)paramsForApi:(ZJAPIBaseManager*)manager;

@end

typedef NS_ENUM(NSUInteger,ZJAPIManagerErrorType){
    ZJAPIManagerErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    ZJAPIManagerErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    ZJAPIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    ZJAPIManagerErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    ZJAPIManagerErrorTypeTimeout,       //请求超时。CTAPIProxy设置的是20秒超时，具体超时时间的设置请自己去看ZJAPIProxy的相关代码。
    ZJAPIManagerErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};

typedef NS_ENUM(NSUInteger,ZJAPIManagerRequestType){
    ZJAPIManagerRequestTypeGet,
    ZJAPIManagerRequestTypePost,
    ZJAPIManagerRequestTypePut,
    ZJAPIManagerRequestTypeDelete
};


/*
 ZJAPIBaseManager的派生类必须符合这些protocal
 */

@protocol ZJAPIManager <NSObject>

@required
-(NSString*)methodName;
-(NSString*)serviceType;
-(ZJAPIManagerRequestType)requestType;
-(BOOL)shouldCache;

@optional
-(void)cleanData;
-(NSDictionary*)reformParams:(NSDictionary*)params;
-(NSInteger)loadDataWithParams:(NSDictionary*)params;
-(BOOL)shouldLoadFromNative;

@end

@protocol ZJAPIManagerInterceptor <NSObject>
@optional
- (BOOL)manager:(ZJAPIBaseManager *)manager beforePerformSuccessWithResponse:(ZJURLResponse *)response;
- (void)manager:(ZJAPIBaseManager *)manager afterPerformSuccessWithResponse:(ZJURLResponse *)response;

- (BOOL)manager:(ZJAPIBaseManager *)manager beforePerformFailWithResponse:(ZJURLResponse *)response;
- (void)manager:(ZJAPIBaseManager *)manager afterPerformFailWithResponse:(ZJURLResponse *)response;

- (BOOL)manager:(ZJAPIBaseManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(ZJAPIBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end

@interface ZJAPIBaseManager : NSObject

@property (nonatomic, weak) id<ZJAPIManagerCallBackDelegate> delegate;
@property (nonatomic, weak) id<ZJAPIManagerParamSource> paramSource;
@property (nonatomic, weak) id<ZJAPIManagerValidator> validator;
@property (nonatomic, weak) NSObject<ZJAPIManager> *child; //里面会调用到NSObject的方法，所以这里不用id
@property (nonatomic, weak) id<ZJAPIManagerInterceptor> interceptor;

/*
 baseManager是不会去设置errorMessage的，派生的子类manager可能需要给controller提供错误信息。所以为了统一外部调用的入口，设置了这个变量。
 派生的子类需要通过extension来在保证errorMessage在对外只读的情况下使派生的manager子类对errorMessage具有写权限。
 */
@property (nonatomic, copy, readonly) NSString *errorMessage;
@property (nonatomic, readonly) ZJAPIManagerErrorType errorType;
@property (nonatomic, strong) ZJURLResponse *response;
@property (nonatomic, assign, readonly) BOOL isReachable;
@property (nonatomic, assign, readonly) BOOL isLoading;

-(id)fetchDataWithReformer:(id<ZJAPIManagerDataReformer>)rformer;
//尽量使用loadData这个方法,这个方法会通过param source来获得参数，这使得参数的生成逻辑位于controller中的固定位置
- (NSInteger)loadData;

-(void)cancelAllRequests;
-(void)cancelRequestWithRequestId:(NSInteger)requestId;

// 拦截器方法，继承之后需要调用一下super
-(BOOL)beforePerformSuccessWithResponse:(ZJURLResponse*)response;
-(void)afterPerformSuccessWithResponse:(ZJURLResponse*)response;

- (BOOL)beforePerformFailWithResponse:(ZJURLResponse *)response;
- (void)afterPerformFailWithResponse:(ZJURLResponse *)response;

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params;
- (void)afterCallingAPIWithParams:(NSDictionary *)params;


/*
 用于给继承的类做重载，在调用API之前额外添加一些参数,但不应该在这个函数里面修改已有的参数。
 子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
 ZJAPIBaseManager会先调用这个函数，然后才会调用到 id<ZJAPIManagerValidator> 中的 manager:isCorrectWithParamsData:
 所以这里返回的参数字典还是会被后面的验证函数去验证的。
 
 假设同一个翻页Manager，ManagerA的paramSource提供page_size=15参数，ManagerB的paramSource提供page_size=2参数
 如果在这个函数里面将page_size改成10，那么最终调用API的时候，page_size就变成10了。然而外面却觉察不到这一点，因此这个函数要慎用。
 
 这个函数的适用场景：
 当两类数据走的是同一个API时，为了避免不必要的判断，我们将这一个API当作两个API来处理。
 那么在传递参数要求不同的返回时，可以在这里给返回参数指定类型。
  
 */

- (NSDictionary *)reformParams:(NSDictionary *)params;
- (void)cleanData;
- (BOOL)shouldCache;

- (void)successedOnCallingAPI:(ZJURLResponse *)response;
- (void)failedOnCallingAPI:(ZJURLResponse *)response withErrorType:(ZJAPIManagerErrorType)errorType;
@end
