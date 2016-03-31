//
//  Transformer.m
//  MakeUp
//
//  Created by iOS Developer 1 on 15/6/18.
//  Copyright (c) 2015年 Joey. All rights reserved.
//

#import "Transformer.h"


@interface Transformer()

@end


@implementation Transformer

singletonImplemention(Transformer)

// dictionary转data
- (NSData*)returnDataWithDictionary:(NSDictionary*)dict
{
    NSMutableData* data = [[NSMutableData alloc]init];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:dict forKey:@"talkData"];
    [archiver finishEncoding];
    
    return data;
}

// data转dictionary
- (NSDictionary*)returnDictionaryWithDataPath:(NSString*)path
{
    NSData* data = [[NSMutableData alloc]initWithContentsOfFile:path];
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    NSDictionary* myDictionary = [unarchiver decodeObjectForKey:@"talkData"];
    [unarchiver finishDecoding];
    return myDictionary;
}

- (NSDictionary*)returnDictionaryWithData:(NSData*)data
{
   // NSData* data = [[NSMutableData alloc]initWithContentsOfFile:path];
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    NSDictionary* myDictionary = [unarchiver decodeObjectForKey:@"talkData"];
    [unarchiver finishDecoding];
    return myDictionary;
}

// 字典转字符串
+ (NSString *)returnStringWithDictionary:(NSDictionary*)dic WithModel:(JsonStringContentMode)model
{
    NSString *str = @"";
    NSError *parseError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (model == JsonModel) {
        return str;
    }else{
        NSScanner *scanner = [[NSScanner alloc] initWithString:str];
        [scanner setCharactersToBeSkipped:nil];
        NSMutableString *result = [[NSMutableString alloc] init];
        NSString *temp;
        NSCharacterSet*newLineAndWhitespaceCharacters = [NSCharacterSet newlineCharacterSet];
        // 扫描
        while (![scanner isAtEnd])
        {
            temp = nil;
            [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
            if (temp) [result appendString:temp];
            
            // 替换换行符
            if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
                if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                    [result appendString:@""];
            }
            
            // 替换转义符
            
        }
        return result;
    }
}
@end
