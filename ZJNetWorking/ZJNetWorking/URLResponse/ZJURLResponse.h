//
//  ZJURLResponse.h
//  ZJNetWorking
//
//  Created by 朱爱俊 on 2017/5/23.
//  Copyright © 2017年 朱爱俊. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, ZJURLResponseStatus)
{
    ZJURLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的ZJAPIBaseManager来决定。
    ZJURLResponseStatusErrorTimeout,
    ZJURLResponseStatusErrorNoNetwork // 默认除了超时以外的错误都是无网络错误。
};

@interface ZJURLResponse : NSObject

@property (nonatomic, assign, readonly) ZJURLResponseStatus status;
@property (nonatomic, copy, readonly) NSString *contentString;
@property (nonatomic, copy, readonly) id content;
@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, copy, readonly) NSURLRequest *request;
@property (nonatomic, copy, readonly) NSData *responseData;
@property (nonatomic, copy) NSDictionary *requestParams;
@property (nonatomic, strong, readonly) NSError *error;

@property (nonatomic, assign, readonly) BOOL isCache;

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(ZJURLResponseStatus)status;
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error;

// 使用initWithData的response，它的isCache是YES，上面两个函数生成的response的isCache是NO
- (instancetype)initWithData:(NSData *)data;

@end
