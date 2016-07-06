//
//  ClickViewController.m
//  WebRequest
//
//  Created by iOS Developer 2 on 16/3/29.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import "ClickViewController.h"
#import "WebRequestManager.h"
#import "ViewController.h"
@interface ClickViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *progresslabel;

@end

@implementation ClickViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
}

- (void) viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    
    self.progressView.progress = 0;
    
    self.progresslabel.text = @"0";
}

- (IBAction) getAction:(UIButton *)sender
{
    
    [SVProgressHUD showWithStatus:@"请求数据中"];
    NSString *URL = [NSString stringWithFormat:@"http://api.douban.com/v2/music/search"];
    
    [WebRequestManager sharedWebRequestManager].requestSerializerType = RequestSerializerTypeForm;
    
    [WebRequestManager sharedWebRequestManager].responseSerializerType = ResponseSerializerTypeJSON;
    
    [[WebRequestManager sharedWebRequestManager] getDataWithURLString:URL WithParams:@{@"q":@"周杰伦"} success:^(id dic) {
        
        [self pushVCWithDic:dic];
        
    } failure:^(NSError *error) {
        
        [self returnFailureWith:error];
    }];
}

- (IBAction) postAction:(UIButton *)sender
{
    
    [SVProgressHUD showWithStatus:@"请求数据中"];
    
    NSString *URL = [NSString stringWithFormat:@"http://www.oschina.net/action/api/user_updaterelation"];
    
    [WebRequestManager sharedWebRequestManager].requestSerializerType = RequestSerializerTypeForm;
    
    [WebRequestManager sharedWebRequestManager].responseSerializerType = ResponseSerializerTypeHTTP;
    
    [[WebRequestManager sharedWebRequestManager] postDataWithURLString:URL WithParams:@{@"uid":@"2544566", @"hisuid":@"1181793", @"newrelation":@"1"}  success:^(id dic) {
        
        [self pushVCWithDic:dic];
        
    } failure:^(NSError *error) {
        
        [self returnFailureWith:error];
    }];
}

- (IBAction) uploadAction:(UIButton *)sender
{
    
    [SVProgressHUD showWithStatus:@"请求数据中"];
    
    NSString *URL = [NSString stringWithFormat:@"http://www.oschina.net/action/api/portrait_update"];
    
    [WebRequestManager sharedWebRequestManager].requestSerializerType = RequestSerializerTypeForm;
    
    [WebRequestManager sharedWebRequestManager].responseSerializerType = ResponseSerializerTypeHTTP;
    
    UIImage *image = [UIImage imageNamed:@"banner"];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    //压缩至100KB以内
    /*    
    NSData *data = UIImageJPEGRepresentation(image, 1);
    
    while (data.length > 100 *1024) {

        data = UIImageJPEGRepresentation(image, 0.8);
    }
     */
    
    [[WebRequestManager sharedWebRequestManager] uploadFileWithURLString:URL WithParams:@{@"uid":@"2544566"} data:data fileSuffixName:@"png" success:^(id dic) {
        
        [self pushVCWithDic:dic];
    } failure:^(NSError *error) {
        
        [self returnFailureWith:error];
    }fractionCompleted:^(double count) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.progressView.progress = count;
            
            self.progresslabel.text = [NSString stringWithFormat:@"%.2f%%",count * 100];
            
        });
    }];
}

- (IBAction) downloadAction:(UIButton *)sender
{
    
    
    [SVProgressHUD showWithStatus:@"请求数据中"];
    
    NSString *URL = [NSString stringWithFormat:@"http://help.adobe.com/archive/en/photoshop/cs6/photoshop_reference.pdf"];
    
    [WebRequestManager sharedWebRequestManager].requestSerializerType = RequestSerializerTypeForm;
    
    [WebRequestManager sharedWebRequestManager].responseSerializerType = ResponseSerializerTypeHTTP;
    
    [[WebRequestManager sharedWebRequestManager] downloadFileWithURLString:URL success:^(id dic) {
        
        [self pushVCWithDic:dic];
    } failure:^(NSError *error) {
        
        [self returnFailureWith:error];
        
    }fractionCompleted:^(double count) {
       
        dispatch_async(dispatch_get_main_queue(), ^{

            self.progressView.progress = count;
            
            self.progresslabel.text = [NSString stringWithFormat:@"%.2f%%",count * 100];
        });
        
    }];
}

- (void) pushVCWithDic:(id)dic
{

    [SVProgressHUD dismiss];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"ViewControllerID"];
    
    VC.dic = dic;
    
    [self.navigationController pushViewController:VC  animated:YES];
}

- (void) returnFailureWith:(NSError *)error
{
    
    NSLog(@"%@",error); 
    
    [SVProgressHUD dismiss];
}

@end
