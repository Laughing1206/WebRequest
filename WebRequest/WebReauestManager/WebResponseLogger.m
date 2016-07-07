//
//  WebResponseLogger.m
//  WebRequest
//
//  Created by 李欢欢 on 16/7/6.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import "WebResponseLogger.h"
#import "AFURLSessionManager.h"
#import <objc/runtime.h>

static NSURLRequest * AFNetworkRequestFromNotification(NSNotification *notification)
{
    NSURLRequest *request = nil;
    if ([[notification object] respondsToSelector:@selector(originalRequest)]) {
        request = [[notification object] originalRequest];
    } else if ([[notification object] respondsToSelector:@selector(request)]) {
        request = [[notification object] request];
    }
    
    return request;
}

static NSError * AFNetworkErrorFromNotification(NSNotification *notification)
{
    NSError *error = nil;
    if ([[notification object] isKindOfClass:[NSURLSessionTask class]]) {
        error = [(NSURLSessionTask *)[notification object] error];
        if (!error) {
            error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
        }
    }
    
    return error;
}

@implementation WebResponseLogger
singletonImplemention(WebResponseLogger)

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.level = AFLoggerLevelInfo;

    return self;
}

- (void)startLogging
{
    [self stopLogging];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)stopLogging
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

static void * AFNetworkRequestStartDate = &AFNetworkRequestStartDate;

- (void)networkRequestDidStart:(NSNotification *)notification
{
    NSURLRequest *request = AFNetworkRequestFromNotification(notification);
    
    if (!request) {
        return;
    }
    
    if (request && self.filterPredicate && [self.filterPredicate evaluateWithObject:request]) {
        return;
    }
    
    objc_setAssociatedObject(notification.object, AFNetworkRequestStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSString *body = nil;
    if ([request HTTPBody]) {
        body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    }
    
    switch (self.level) {
        case AFLoggerLevelDebug:
            NSLog(@"%@ '%@': %@ %@", [request HTTPMethod], [[request URL] absoluteString], [request allHTTPHeaderFields], body);
            break;
        case AFLoggerLevelInfo:
            NSLog(@"%@ '%@'", [request HTTPMethod], [[request URL] absoluteString]);
            break;
        default:
            break;
    }
}

- (void)networkRequestDidFinish:(NSNotification *)notification
{
    NSURLRequest *request = AFNetworkRequestFromNotification(notification);
    NSURLResponse *response = [notification.object response];
    NSError *error = AFNetworkErrorFromNotification(notification);
    
    if (!request && !response) {
        return;
    }
    
    if (request && self.filterPredicate && [self.filterPredicate evaluateWithObject:request]) {
        return;
    }
    
    NSUInteger responseStatusCode = 0;
    NSDictionary *responseHeaderFields = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        responseStatusCode = (NSUInteger)[(NSHTTPURLResponse *)response statusCode];
        responseHeaderFields = [(NSHTTPURLResponse *)response allHeaderFields];
    }
    
    id responseObject = notification.userInfo[AFNetworkingTaskDidCompleteSerializedResponseKey];
    if (responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            responseObject = [[NSDictionary alloc] initWithDictionary:responseObject];
        }
        else if ([responseObject isKindOfClass:[NSData class]]) {
            NSStringEncoding stringEncoding = NSUTF8StringEncoding;
            responseObject = [[NSString alloc] initWithData:responseObject encoding:stringEncoding];
        }
    }
    
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(notification.object, AFNetworkRequestStartDate)];
    
    if (error) {
        switch (self.level) {
            case AFLoggerLevelDebug:
            case AFLoggerLevelInfo:
            case AFLoggerLevelWarn:
            case AFLoggerLevelError:
                NSLog(@"[Error] %@ '%@' (%ld) [%.04f s]: %@", [request HTTPMethod], [[response URL] absoluteString], (long)responseStatusCode, elapsedTime, error);
            default:
                break;
        }
    } else {
        switch (self.level) {
            case AFLoggerLevelDebug:
                NSLog(@"%ld '%@' [%.04f s]: %@ %@", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime, responseHeaderFields, responseObject);
                break;
            case AFLoggerLevelInfo:
                NSLog(@"%ld '%@' [%.04f s]", (long)responseStatusCode, [[response URL] absoluteString], elapsedTime);
                break;
            default:
                break;
        }
    }
}

- (void)dealloc
{
    [self stopLogging];
}

@end
