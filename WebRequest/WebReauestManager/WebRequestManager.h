//
//  WebRequestManager.h
//  WebRequest
//
//  Created by iOS Developer 2 on 16/3/31.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "singleton.h"

typedef NS_ENUM(NSInteger, RequestSerializerType) {

    RequestSerializerTypeForm = 0,//默认

    RequestSerializerTypeJSON
};


typedef NS_ENUM(NSInteger, ResponseSerializerType) {

    ResponseSerializerTypeJSON= 0,//默认

    ResponseSerializerTypeHTTP
};
@interface WebRequestManager : NSObject

singletonInterface(WebRequestManager)

@property (nonatomic, assign) RequestSerializerType  requestSerializerType;

@property (nonatomic, assign) ResponseSerializerType responseSerializerType;

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
 *  @param URLString      数据接口
 *  @param params         数据体
 *  @param data           上传的文件data
 *  @param fileSuffixName 上传的文件后缀名
 *  @param success        成功回调block
 *  @param failure        失败回调block
 */
- (void) uploadFileWithURLString:(NSString *)URLString 
                      WithParams:(id)params
                            data:(NSData *)data 
                  fileSuffixName:(NSString *)fileSuffixName
                         success:(void(^)(id dic))success 
                         failure:(void(^)(NSError *error))failure
               fractionCompleted:(void(^)(double count))fractionCompleted;

/**
 *  下载文件
 *
 *  @param URLString         数据接口
 *  @param success           成功回调block
 *  @param failure           失败回调block
 *  @param fractionCompleted 进度
 */
- (void) downloadFileWithURLString:(NSString *)URLString 
                           success:(void(^)(id dic))success 
                           failure:(void(^)(NSError *error))failure
                 fractionCompleted:(void(^)(double count))fractionCompleted;
/**
 *  取消请求
 */
- (void)cancelRequest;

@end
