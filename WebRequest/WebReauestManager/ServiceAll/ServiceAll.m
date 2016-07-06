//
//  ServiceAll.m
//  WebRequest
//
//  Created by 李欢欢 on 16/7/6.
//  Copyright © 2016年 Laughing. All rights reserved.
//

#import "ServiceAll.h"
#import "SphereMenu.h"

@interface ServiceAll () <SphereMenuDelegate>
@property (nonatomic, strong) SphereMenu * sphereMenu;
@end
@implementation ServiceAll
singletonImplemention(ServiceAll)

- (void)loadServiceAll
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( 1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupDock];
    });

}

- (void)setupDock
{
    UIImage *startImage = [UIImage imageNamed:@"start"];
    UIImage *image1 = [UIImage imageNamed:@"icon-api"];
    UIImage *image2 = [UIImage imageNamed:@"icon-log"];
    UIImage *image3 = [UIImage imageNamed:@"icon-ui"];
    
    NSArray *images = @[image1, image2, image3];
    
    self.sphereMenu = [[SphereMenu alloc] initWithStartPoint:CGPointMake( [UIScreen mainScreen].bounds.size.width - 30, [UIScreen mainScreen].bounds.size.height - 200 )
                                                  startImage:startImage
                                               submenuImages:images];
    self.sphereMenu.delegate = self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.sphereMenu];
    
    [[UIApplication sharedApplication].keyWindow addObserver:self forKeyPath:@"rootViewController" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self reloadDock];
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"rootViewController"];
}

- (void)reloadDock
{
    [self.sphereMenu removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self.sphereMenu];
}

- (void)sphereDidSelected:(int)index
{
    switch ( index )
    {
        case 0:
        {
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
        }
            break;
            
        default:
            break;
    }
}
@end
