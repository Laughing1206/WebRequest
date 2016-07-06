//
//  WebResponseLogger.h
//  WebRequest
//
//  Created by 李欢欢 on 16/7/6.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTTPRequestLoggerLevel) {
    AFLoggerLevelOff,
    AFLoggerLevelDebug,
    AFLoggerLevelInfo,
    AFLoggerLevelWarn,
    AFLoggerLevelError,
    AFLoggerLevelFatal = AFLoggerLevelOff,
};

@interface WebResponseLogger : NSObject

@property (nonatomic, assign) HTTPRequestLoggerLevel level;

@property (nonatomic, strong) NSPredicate *filterPredicate;

+ (instancetype)sharedLogger;

- (void)startLogging;

- (void)stopLogging;

@end
