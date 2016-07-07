//
//  WebResponseLogger.h
//  WebRequest
//
//  Created by 李欢欢 on 16/7/6.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AFHTTPRequestLoggerLevel) {
    AFLoggerLevelOff,
    AFLoggerLevelDebug,
    AFLoggerLevelInfo,
    AFLoggerLevelWarn,
    AFLoggerLevelError,
    AFLoggerLevelFatal = AFLoggerLevelOff,
};

@interface WebResponseLogger : NSObject

singletonInterface(WebResponseLogger)

@property (nonatomic, assign) AFHTTPRequestLoggerLevel level;

@property (nonatomic, strong) NSPredicate *filterPredicate;

- (void)startLogging;

- (void)stopLogging;

@end
