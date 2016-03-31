# WebRequest

基于AFNetWorking 3.0封装的http请求

已实现

#GET:

[SVProgressHUD showWithStatus:@"请求数据中"];
NSString *URL = [NSString stringWithFormat:@"http://api.douban.com/v2/music/search"];

[WebRequestManager sharedWebRequestManager].requestSerializerType = RequestSerializerTypeForm;

[WebRequestManager sharedWebRequestManager].responseSerializerType = ResponseSerializerTypeJSON;

[[WebRequestManager sharedWebRequestManager] getDataWithURLString:URL WithParams:@{@"q":@"周杰伦"} success:^(id dic) {

[self pushVCWithDic:dic];

} failure:^(NSError *error) {

[self returnFailureWith:error];
}];


#POST:

[SVProgressHUD showWithStatus:@"请求数据中"];

NSString *URL = [NSString stringWithFormat:@"http://www.oschina.net/action/api/user_updaterelation"];

[WebRequestManager sharedWebRequestManager].requestSerializerType = RequestSerializerTypeForm;

[WebRequestManager sharedWebRequestManager].responseSerializerType = ResponseSerializerTypeHTTP;

[[WebRequestManager sharedWebRequestManager] postDataWithURLString:URL WithParams:@{@"uid":@"2544566", @"hisuid":@"1181793", @"newrelation":@"1"}  success:^(id dic) {

[self pushVCWithDic:dic];

} failure:^(NSError *error) {

[self returnFailureWith:error];
}];


#Upload:

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


#Download:

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

#pragma mark - 公共方法
- (void) pushVCWithDic:(id)dic {

[SVProgressHUD dismiss];

UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

ViewController *VC = [storyboard instantiateViewControllerWithIdentifier:@"ViewControllerID"];

VC.dic = dic;

[self.navigationController pushViewController:VC  animated:YES];
}

- (void) returnFailureWith:(NSError *)error {

NSLog(@"%@",error); 

[SVProgressHUD dismiss];
}







