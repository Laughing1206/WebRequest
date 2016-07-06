//
//  STIPinView.h
//  gaibianjia
//
//  Created by QFish on 7/19/15.
//  Copyright (c) 2015 Geek Zoo Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
        Padding
		   X
 +---------X-----------+
 |         X           |
 | +-----------------+ |
 | | VerticalBounds  | |
 | +-----------------+ |
 | |                 | |
 | |                 | |
 | |                 | |
 | +-----------------+ |
 | | VerticalBounds  | |
 | +-----------------+ |
 |                     |
 +---------------------+
 
 */

@interface STIPinView : UIView
@property (nonatomic, assign) CGFloat padding; // default 8.
@property (nonatomic, assign) CGFloat verticalBounds; // the bounds of top and bottom, default 80.
@property (nonatomic, assign) BOOL notChangeAlpha;
- (void)touchesEnded:(CGPoint)point;
@end
