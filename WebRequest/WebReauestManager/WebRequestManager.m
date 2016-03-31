//
//  WebRequestManager.m
//  WebRequest
//
//  Created by iOS Developer 2 on 16/3/31.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import "WebRequestManager.h"
#import "WebRequestSession.h"
#import "Transformer.h"
#import "NSString+Hash.h"

#define  kWebCachePath [NSTemporaryDirectory() stringByAppendingString:@"cache"]
#define  kWebBaseURLPath @""

@interface WebRequestManager ()

@property (nonatomic,strong) WebRequestSession   *webRequestSession;     //session请求

@property (nonatomic,strong) NSMutableDictionary *operationCachePool;    //初始化操作缓存池

@property (nonatomic,copy  ) NSString            *webTask;               //缓存名

@property (nonatomic,assign) BOOL                isCanceled;             //是否取消网络请求

@end

@implementation WebRequestManager

singletonImplemention(WebRequestManager)

// 初始化操作缓存池
- (NSMutableDictionary *)operationCachePool {
    
    if (_operationCachePool == nil) {
        
        _operationCachePool = [[NSMutableDictionary alloc] init];
    
    }

    return _operationCachePool;
}

// GET请求
- (void) getDataWithURLString:(NSString *)URLString 
                   WithParams:(id)params 
                      success:(void(^)(id dic))success 
                      failure:(void(^)(NSError *error))failure {
    
    
    URLString = [self beforeRequestWithSettingWithURLString:URLString];
    
    WebRequestSession *requestSession = [[WebRequestSession alloc]init];
    
    [self.operationCachePool setObject:requestSession forKey:URLString];
    
    self.webRequestSession = requestSession;
    
    [requestSession getDataWithURLString:URLString WithParams:params success:^(id dic) {
        
        [self setReturnSuccessWithSuccess:success URLString:URLString returnData:dic];
        
    } failure:^(NSError *error) {
        
        [self BlockWith:error success:success failure:failure];
    
    }];
}

// POST请求
- (void) postDataWithURLString:(NSString *)URLString 
                    WithParams:(id)params 
                       success:(void(^)(id dic))success 
                       failure:(void(^)(NSError *error))failure {
    
    URLString = [self beforeRequestWithSettingWithURLString:URLString];
    
    WebRequestSession *requestSession = [[WebRequestSession alloc]init];

    self.webRequestSession = requestSession;

    [self.operationCachePool setObject:requestSession forKey:URLString];
    
    [requestSession postDataWithURLString:URLString WithParams:params success:^(id dic) {
           
        [self setReturnSuccessWithSuccess:success URLString:URLString returnData:dic];
        
    } failure:^(NSError *error) {
        
        [self BlockWith:error success:success failure:failure];

    }];
    
}

// Upload请求
- (void) uploadFileWithURLString:(NSString *)URLString 
                      WithParams:(id)params
                            data:(NSData *)data 
                  fileSuffixName:(NSString *)fileSuffixName
                         success:(void(^)(id dic))success 
                         failure:(void(^)(NSError *error))failure {
    
    WebRequestSession *requestSession = [[WebRequestSession alloc]init];

    self.webRequestSession = requestSession;
    
    NSString *name = [[self getDate] md5String];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",name,fileSuffixName];
    
    [requestSession uploadFileWithURLString:URLString WithParams:params data:data name:name fileName:fileName success:^(id dic) {
        
        if (success) {
            
            success(dic);
        }
        
    } failure:^(NSError *error) {
        
        self.isCanceled = NO;
        
        if (failure) {
            
            failure(error);
        }
        
    }];
    
}

- (void) downloadFileWithURLString:(NSString *)URLString 
                           success:(void(^)(id dic))success 
                           failure:(void(^)(NSError *error))failure {

    URLString = [self beforeRequestWithSettingWithURLString:URLString];
    
    WebRequestSession *requestSession = [[WebRequestSession alloc]init];
    
    self.webRequestSession = requestSession;
    
    [self.operationCachePool setObject:requestSession forKey:URLString];
    
    [requestSession downloadFileWithURLString:URLString success:^(id dic) {
        
        if (success) {
            
            success(dic);
        };
    } failure:^(NSError *error) {
        
        self.isCanceled = NO;
        
        if (failure) {
            
            failure(error);
        }
    }];

}
// 请求前设置
- (NSString *) beforeRequestWithSettingWithURLString:(NSString *)URLString {
    
    URLString = [NSString stringWithFormat:@"%@%@",kWebBaseURLPath,URLString];
    
    self.webTask = URLString;
    
    if ([self.operationCachePool objectForKey:self.webTask]) {
        
        NSLog(@"正在请求");
        
    }
    
    return URLString;
}

// 请求数据成功
- (void) setReturnSuccessWithSuccess:(void(^)(id dic))success URLString:(NSString *)URLString returnData:(id)dic {
    
    if ([self.operationCachePool objectForKey:self.webTask]) {
        
        [self.operationCachePool removeObjectForKey:self.webTask];
  
    }
    
    NSString *hash = [self.webTask md5String];
    
    NSString *filePath = [self pathForDocumentWithComponent:hash];
    
    NSData *data = [[Transformer sharedTransformer] returnDataWithDictionary:dic];
    
    [data writeToFile:filePath atomically:YES];
    
    if (success) {
        
        success(dic);
    }
    
    [self.operationCachePool removeObjectForKey:URLString];
    
}

// 请求数据失败
- (void)BlockWith:(NSError*)error success:(void(^)(id dic))success failure:(void(^)(NSError *error))failure {
    
    if (self.isCanceled) {
        
        self.isCanceled = NO;
        
        if (failure) {
            
            failure(error);
        }
        
    }else{
        
        NSLog(@"%@",self.webTask);
        
        NSString *hash = [self.webTask md5String];
        
        NSString *filePath = [self pathForDocumentWithComponent:hash];
        
        NSLog(@"%@",filePath);
        
        NSDictionary *dic = [[Transformer sharedTransformer] returnDictionaryWithDataPath:filePath];
        
        if(dic){
            
            NSLog(@"%@",dic);
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                
                if (success) {
                    
                    success(dic);
                }
                
                NSLog(@"网络不畅，缓存中取~~~~~~~~");
            }
            
        }else {
            
            NSLog(@"%@~~~",dic);
            
            if (failure) {
                
                failure(error);
            }
        }
    }    
}

// 获取沙盒路径
- (NSString *)pathForDocumentWithComponent:(NSString *)fid {
    
    NSString *fullPath = nil;
    
    if (fid&& [fid length]) {
        
        NSString *path = NSHomeDirectory();
        
        NSString *cacheDiretory= [path stringByAppendingPathComponent:@"Library/Caches/"];
        
        cacheDiretory = [cacheDiretory stringByAppendingPathComponent:@"webCache"];
        
        fullPath = [cacheDiretory stringByAppendingPathComponent:fid];
        
    } else {
        
        fullPath = kWebCachePath;
        
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:fullPath]) {
        
        NSError *err=nil;
        
        if ([fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&err]) {
            
            return [fullPath stringByAppendingPathComponent:fid];
            
        }else{
            
            [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&err];
            
            return [fullPath stringByAppendingPathComponent:fid];
        }
    }
    
    fullPath = [fullPath stringByAppendingPathComponent:fid];
    
    return fullPath;
}

//取消请求
- (void)cancelRequest {
    
    if (self.operationCachePool.count) {
        
        [self.operationCachePool removeAllObjects];
        
        [self.webRequestSession cancelRequest];
        
        self.isCanceled = YES;
    }
    
}

// 获取当前时间
- (NSString*)getDate {
    
    NSDate* now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
    
    [dateFormatter setDateFormat:@"yyyy/MM/dd  HH:mm:ss"];
    
    NSLog(@"%@",[dateFormatter stringFromDate:now]);
    
    return [dateFormatter stringFromDate:now];
}

@end
