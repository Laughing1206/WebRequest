//
//  WebRequestSession.h
//  WebRequest
//
//  Created by iOS Developer 2 on 16/3/31.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface WebRequestSession : NSObject

/**
 *  请求管理者
 */
@property (nonatomic,strong)AFHTTPSessionManager *requestManager;

/**
 *  JsonGET请求,getJson方法，afn返回数据类型为NSFoundation类型
 *
 *  @param URLString 数据接口
 *  @param params    数据体
 *  @param success   成功回调block
 *  @param failure   失败回调block
 */
- (void) getDataWithURLString:(NSString *)URLString 
                   WithParams:(id)params 
                      success:(void(^)(id dic))success 
                      failure:(void(^)(NSError *error))failure;


/**
 *  JsonPOST请求,post网络请求
 *
 *  @param URLString 数据接口
 *  @param params    数据体
 *  @param success   成功回调block
 *  @param failure   失败回调block
 */
- (void) postDataWithURLString:(NSString *)URLString 
                    WithParams:(id)params 
                       success:(void(^)(id dic))success 
                       failure:(void(^)(NSError *error))failure;

/**
 *  上传文件
 *
 *  @param URLString 数据接口
 *  @param params    数据体
 *  @param image     上传的图片
 *  @param name      图片名
 *  @param fileName  图片文件名
 *  @param success   成功回调block
 *  @param failure   失败回调block
 */
- (void) uploadFileWithURLString:(NSString *)URLString 
                      WithParams:(id)params
                            data:(NSData *)data 
                            name:(NSString *)name 
                        fileName:(NSString *)fileName 
                         success:(void(^)(id dic))success 
                         failure:(void(^)(NSError *error))failure;

/**
 *  取消请求
 */
- (void)cancelRequest;

@end
