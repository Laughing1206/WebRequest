//
//  ViewController.m
//  WebRequest
//
//  Created by iOS Developer 2 on 16/3/29.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView.text = [self dictionaryToData:self.dic];
    NSLog(@"%@",self.dic);
}

- (NSString*) dictionaryToData:(id)dic {

    if ([dic isKindOfClass:[NSDictionary class]]) {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }else if ([dic isKindOfClass:[NSURL class]]) {
    
        dic = [NSString stringWithFormat:@"%@",dic];
    }else{
    
        dic = [[NSString alloc] initWithData:dic encoding:NSUTF8StringEncoding];
    }
    
    return dic;
}



@end
