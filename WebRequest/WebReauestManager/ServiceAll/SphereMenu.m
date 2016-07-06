//
//  SphereMenu.m
//  SphereMenu
//
//  Created by Tu You on 14-8-24.
//  Copyright (c) 2014年 TU YOU. All rights reserved.
//

#import "SphereMenu.h"

static const CGFloat kAngleOffset = M_PI_2 / 2;
static const CGFloat kSphereLength = 80;
static const float kSphereDamping = 0.3;

@interface SphereMenu () <UICollisionBehaviorDelegate>

@property (assign, nonatomic) NSUInteger count ;
@property (strong, nonatomic) UIImageView *start;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSMutableArray *positions;

// animator and behaviors
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UICollisionBehavior *collision;
@property (strong, nonatomic) UIDynamicItemBehavior *itemBehavior;
@property (strong, nonatomic) NSMutableArray *snaps;
@property (strong, nonatomic) NSMutableArray *taps;

@property (strong, nonatomic) UITapGestureRecognizer *tapOnStart;

@property (strong, nonatomic) id<UIDynamicItem> bumper;
@property (assign, nonatomic) BOOL expanded;
@property (assign, nonatomic) BOOL isExpanded;
@property (nonatomic, assign) CGFloat positionIndex;
@end

@implementation SphereMenu

- (void)touchesEnded:(CGPoint)point
{
    [super touchesEnded:point];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setPositionIndex];
        [self updatePositions];
        [self shrinkSubmenu];
        self.start.highlighted = NO;
    });
}

- (void)updatePositions
{
    [self.positions removeAllObjects];
    
    for (int i = 0; i < self.items.count; i++ )
    {
        CGPoint position = [self centerForSphereAtIndex:i];
        [self.positions addObject:[NSValue valueWithCGPoint:position]];
    }
}

- (instancetype)initWithStartPoint:(CGPoint)startPoint startImage:(UIImage *)startImage submenuImages:(NSArray *)images
{
    if (self = [super init]) {
        //self.backgroundColor = [UIColor whiteColor];
        self.bounds = CGRectMake(0, 0, startImage.size.width, startImage.size.height);
        self.center = startPoint;
        
        self.images = images;
        
        self.count = self.images.count;
        self.start = [[UIImageView alloc] initWithImage:startImage];
        self.start.highlightedImage = [UIImage imageNamed:@"end.png"];
        //self.start.backgroundColor = [UIColor greenColor];
   
        self.start.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.9].CGColor;
        self.start.layer.borderWidth = 1.3;
        self.start.layer.cornerRadius = 25;
        self.start.userInteractionEnabled = YES;
        self.tapOnStart = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(startTapped:)];
        [self.start addGestureRecognizer:self.tapOnStart];
        [self addSubview:self.start];
    }
    return self;
}

- (void)setPositionIndex
{
    if ( self.center.x > 50 && self.center.x < [UIScreen mainScreen].bounds.size.width - 50 && self.center.y > 50 )
    {
        //bottom
        self.positionIndex = 1;
    }
    else if ( self.center.x > 50 && self.center.x < [UIScreen mainScreen].bounds.size.width - 50 && self.center.y < 50)
    {
        //top
        self.positionIndex = 2;
    }
    else if ( self.center.x < 50 && self.center.y > 50 && self.center.y < [UIScreen mainScreen].bounds.size.height - 50 )
    {
        //right
        self.positionIndex = 1.5;
    }
    else if ( self.center.x > [UIScreen mainScreen].bounds.size.width - 50 && self.center.y > 50 && self.center.y < [UIScreen mainScreen].bounds.size.height - 50 )
    {
        //left
        self.positionIndex = 2.5;
    }
    else if ( self.center.x <= 50 && self.center.y <= 50 )
    {
        //左上
        self.positionIndex = 1.75;
    }
    else if ( self.center.x >= [UIScreen mainScreen].bounds.size.width - 50 && self.frame.origin.y <= 50 )
    {
        //右上
        self.positionIndex = 2.25;
    }
    else if ( self.center.x <= 50 && self.center.y >= [UIScreen mainScreen].bounds.size.height - 50 )
    {
        //左下
        self.positionIndex = 1.25;
    }
    else if ( self.center.x >= [UIScreen mainScreen].bounds.size.width - 50 && self.center.y >= [UIScreen mainScreen].bounds.size.height - 50 )
    {
        //右下
        self.positionIndex = 0.75;
    }
    else
    {
        self.positionIndex = 2.5;
    }
}

- (void)commonSetup
{
    self.items = [NSMutableArray array];
    self.positions = [NSMutableArray array];
    self.snaps = [NSMutableArray array];

    [self setPositionIndex];
    
    // setup the items
    for (int i = 0; i < self.count; i++) {
        UIImageView *item = [[UIImageView alloc] initWithImage:self.images[i]];
     
        item.tag = i;
        item.userInteractionEnabled = YES;
        [self.superview addSubview:item];
        
        CGPoint position = [self centerForSphereAtIndex:i];
        item.center = self.center;
        [self.positions addObject:[NSValue valueWithCGPoint:position]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [item addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        [item addGestureRecognizer:pan];
        
        [self.items addObject:item];
    }
    
    [self.superview bringSubviewToFront:self];
    
    // setup animator and behavior
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    
    self.collision = [[UICollisionBehavior alloc] initWithItems:self.items];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    self.collision.collisionDelegate = self;
    
    for (int i = 0; i < self.count; i++) {
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[i] snapToPoint:self.center];
        snap.damping = kSphereDamping;
        [self.snaps addObject:snap];
    }
    
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.items];
    self.itemBehavior.allowsRotation = NO;
    self.itemBehavior.elasticity = 1.2;
    self.itemBehavior.density = 0.5;
    self.itemBehavior.angularResistance = 5;
    self.itemBehavior.resistance = 10;
    self.itemBehavior.elasticity = 0.8;
    self.itemBehavior.friction = 0.5;
}

- (void)didMoveToSuperview
{
    [self commonSetup];
}

- (void)removeFromSuperview
{
    for (int i = 0; i < self.count; i++) {
        [self.items[i] removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (CGPoint)centerForSphereAtIndex:(int)index
{
    CGFloat firstAngle = M_PI*self.positionIndex + (M_PI_2 - kAngleOffset) + index * kAngleOffset;
    CGPoint startPoint = self.center;
    CGFloat x = startPoint.x + cos(firstAngle) * kSphereLength;
    CGFloat y = startPoint.y + sin(firstAngle) * kSphereLength;
    CGPoint position = CGPointMake(x, y);
    return position;
}

- (void)tapped:(UITapGestureRecognizer *)gesture
{
    self.start.highlighted = NO;
    NSUInteger index = gesture.view.tag;
    
    if ([self.delegate respondsToSelector:@selector(sphereDidSelected:)]) {
        [self.delegate sphereDidSelected:(int)index];
    }
    
    [self.animator removeBehavior:self.collision];
    [self.animator removeBehavior:self.itemBehavior];
    [self removeSnapBehaviors];
    [self shrinkSubmenu];
    self.expanded = false;
}

- (void)startTapped:(UITapGestureRecognizer *)gesture
{
    self.start.highlighted = !self.start.isHighlighted;
    [self.animator removeBehavior:self.collision];
    [self.animator removeBehavior:self.itemBehavior];
    [self removeSnapBehaviors];
    
    if (self.expanded) {
        [self shrinkSubmenu];
    } else {
        [self expandSubmenu];
    }
}

- (void)expandSubmenu
{
    self.expanded = YES;
    
    for (int i = 0; i < self.count; i++)
    {
        [self snapToPostionsWithIndex:i];
    }
}

- (void)shrinkSubmenu
{
    self.expanded = NO;
    
    for (int i = 0; i < self.count; i++)
    {
        [self snapToStartWithIndex:i];
    }
}

- (void)panned:(UIPanGestureRecognizer *)gesture
{
    UIView *touchedView = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.itemBehavior];
        [self.animator removeBehavior:self.collision];
        [self removeSnapBehaviors];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        touchedView.center = [gesture locationInView:self.superview];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.bumper = touchedView;
        [self.animator addBehavior:self.collision];
        NSUInteger index = [self.items indexOfObject:touchedView];
        
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2
{
    [self.animator addBehavior:self.itemBehavior];
    
    if (item1 != self.bumper) {
        NSUInteger index = (int)[self.items indexOfObject:item1];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
    
    if (item2 != self.bumper) {
        NSUInteger index = (int)[self.items indexOfObject:item2];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
}

- (void)snapToStartWithIndex:(NSUInteger)index
{
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[index] snapToPoint:self.center];
    snap.damping = kSphereDamping;
    UISnapBehavior *snapToRemove = self.snaps[index];
    self.snaps[index] = snap;
    [self.animator removeBehavior:snapToRemove];
    [self.animator addBehavior:snap];
}

- (void)snapToPostionsWithIndex:(NSUInteger)index
{
    id positionValue = self.positions[index];
    CGPoint position = [positionValue CGPointValue];
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[index] snapToPoint:position];
    snap.damping = kSphereDamping;
    UISnapBehavior *snapToRemove = self.snaps[index];
    self.snaps[index] = snap;
    [self.animator removeBehavior:snapToRemove];
    [self.animator addBehavior:snap];
}

- (void)removeSnapBehaviors
{
    [self.snaps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.animator removeBehavior:obj];
    }];
}

@end
