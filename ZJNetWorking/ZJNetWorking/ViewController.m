//
//  ViewController.m
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import "ViewController.h"
#import "BaseManager.h"
#import "BaseApiManager.h"
#import "RACReturnSignal.h"
@interface ViewController ()<ZJAPIManagerParamSource,ZJAPIManagerCallBackDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (nonatomic, strong) BaseManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
////    [[[@[@"you", @"are", @"beautiful"] rac_sequence].signal
////      map:^id(NSString * value) {
////          return [value capitalizedString];
////      }] subscribeNext:^(id x) {
////          NSLog(@"capitalizedSignal --- %@", x);
////      }];
//    [self.manager loadData];
//    
//    [self signalSwitch];
    
//    BaseApiManager *apiManager = [[BaseApiManager alloc] init];
//    apiManager.params = @{};
//    apiManager.methodName = @"/api_app/api/app/usercenter/getUserPersonalInfo";
//    apiManager.requestType = APIManagerRequestTypePost;
//    
//    [[[apiManager loadData] flattenMap:^RACStream *(NSDictionary* userInfo ) {
//        return [apiManager loadData];
//    }] subscribeError:^(NSError *error) {
//        ;
//    } completed:^{
//        ;
//    }];
    
//    [_textFiled.rac_textSignal subscribeNext:^(id x) {
//        NSLog(@"content:%@",x);
//    }];
    
//    [[_textFiled.rac_textSignal bind:^RACStreamBindBlock{
//        NSLog(@"test");
//        return ^RACStream *(id value,BOOL *stop){
//            return [RACReturnSignal return: [NSString stringWithFormat:@"输出:%@",value]];
//        };
//    }] subscribeNext:^(id x) {
//        NSLog(@"content:%@",x);
//    }];
    
//    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        
//        [subscriber sendNext:@1];
//        
//        [subscriber sendCompleted];
//        
//        return nil;
//    }];
//    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        
//        [subscriber sendNext:@2];
//        
//        return nil;
//    }];
//    
//    RACSignal *concatSignal = [signalA concat:signalB];
//    
//    // 以后只需要面对拼接信号开发。
//    // 订阅拼接的信号，不需要单独订阅signalA，signalB
//    // 内部会自动订阅。
//    // 注意：第一个信号必须发送完成，第二个信号才会被激活
//    [concatSignal subscribeNext:^(id x) {
//        
//        NSLog(@"%@",x);
//        
//    }];
//    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return nil;
//    }] then:^RACSignal *{
//        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            [subscriber sendNext:@2];
//            return nil;
//        }];
//    }] subscribeNext:^(id x) {
//        
//        // 只能接收到第二个信号的值，也就是then返回信号的值
//        NSLog(@"%@",x);
//    }];
//    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        
//        return nil;
//    }];
//    
//    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        
//        [subscriber sendNext:@2];
//        
//        return nil;
//    }];
//    
//    // 合并信号,任何一个信号发送数据，都能监听到.
//    RACSignal *mergeSignal = [signalA merge:signalB];
//    
//    [mergeSignal subscribeNext:^(id x) {
//        
//        NSLog(@"%@",x);
//        
//    }];
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    
    
    // 压缩信号A，信号B
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    [zipSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}
- (void)signalSwitch {
    //创建3个自定义信号
    RACSubject *google = [RACSubject subject];
    RACSubject *baidu = [RACSubject subject];
    RACSubject *signalOfSignal = [RACSubject subject];
    
    //获取开关信号
    RACSignal *switchSignal = [signalOfSignal switchToLatest];
    
    //对通过开关的信号量进行操作
    [[switchSignal  map:^id(NSString * value) {
        return [@"https//www." stringByAppendingFormat:@"%@", value];
    }] subscribeNext:^(NSString * x) {
        NSLog(@"%@", x);
    }];
    
    
    //通过开关打开baidu
    [signalOfSignal sendNext:baidu];
    [baidu sendNext:@"baidu.com"];
//    [google sendNext:@"google.com"];
    
    //通过开关打开google
    [signalOfSignal sendNext:google];
//    [baidu sendNext:@"baidu.com/"];
    [google sendNext:@"google.com/"];
}

- (NSDictionary *)paramsForApi:(ZJAPIBaseManager *)manager
{
    return nil;
}
#pragma mark - CTAPIManagerCallBackDelegate
- (void)managerCallAPIDidSuccess:(ZJAPIBaseManager *)manager
{
    if (manager == self.manager) {
        
        NSLog(@"%@", [manager fetchDataWithReformer:nil]);
        
    }
}

- (void)managerCallAPIDidFlaied:(ZJAPIBaseManager *)manager
{
    if (manager == self.manager) {
        NSLog(@"%@", [manager fetchDataWithReformer:nil]);
    }
}

-(BaseManager*)manager
{
    if (!_manager){
        _manager = [[BaseManager alloc] init];
        _manager.delegate = self;
        _manager.paramSource = self;
    }
    return _manager;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
