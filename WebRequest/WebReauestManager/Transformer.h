//
//  Transformer.h
//  MakeUp
//
//  Created by iOS Developer 1 on 15/6/18.
//  Copyright (c) 2015年 Joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "singleton.h"
@interface Transformer : NSObject
singletonInterface(Transformer)

typedef NS_ENUM(NSInteger, JsonStringContentMode) {
    JsonModel = 0,
    ServiceModel,
};

/**
 *  字典转data（解归档的形式）
 *
 *  @param dict dic
 *
 *  @return 返回一个data
 */
- (NSData*)returnDataWithDictionary:(NSDictionary*)dict;
/**
 *  data转字典（解归档的形式）
 *
 *  @param path data路径
 *
 *  @return 返回一个字典
 */
- (NSDictionary*)returnDictionaryWithDataPath:(NSString*)path;

- (NSDictionary*)returnDictionaryWithData:(NSData*)data;


/**
 *  字典转字符串
 *
 *  @param dic   dic
 *  @param model 字符串的格式
 *
 *  @return 返回一个转换完成的字符串
 */
+ (NSString *)returnStringWithDictionary:(NSDictionary*)dic WithModel:(JsonStringContentMode)model;
@end
