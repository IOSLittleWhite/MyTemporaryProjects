//
//  JZTabBarController.m
//  JZBPM_MI
//
//  Created by JZ_Stone on 14-7-3.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JZTabBarController.h"

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
static JZTabBarController *_tabBarControllerSingleTon = nil;

@interface JZTabBarController ()
{
    UIView *_transitionView; // 自带的UITranstionView
    CGFloat _sideSet; // 偏移的像素
    JZRevealSideDirection _direction; // 偏移方向
    UIPanGestureRecognizer *_panGesture;// 滑动手势，用于拖拽出或收起底层菜单，当没有菜单时应该移除
    UIView *_frontView; // 侧滑后用于覆盖侧滑后的window，将单击回弹手势和滑动手势加于其上，会弹后移除该view
    CGPoint _startPan;
    BOOL _isMoving;
    BOOL _havePush; // 是否已经push出侧边栏
    BOOL _isPanNavDragDelegate; // 是否当前滑动手势传递到navDragDelegate
    BOOL _isPanSelfView; // 是否当前滑动手势作用在自己的view
    UIView *_sideView;
}

@end


@implementation JZTabBarController
// 单例话分栏控制器
+ (JZTabBarController *)sharedTabBarController
{
    if(_tabBarControllerSingleTon == nil)
    {
        _tabBarControllerSingleTon = [[JZTabBarController alloc] init];
    }
    return _tabBarControllerSingleTon;
}

#pragma mark - 生命周期函数
- (instancetype)init
{
    if (_tabBarControllerSingleTon == nil)
    {
        _tabBarControllerSingleTon = [super init];
        
        _havePush = false;
        _isNeedToBeDark = NO;
        _isNeedShadow = NO;
        
        for(UIView *view in self.view.subviews)
        {
            if([view isKindOfClass:[UITabBar class]])
            {
                [view removeFromSuperview];
            }
            else
            {
                view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                view.backgroundColor = [UIColor whiteColor];
                _transitionView = view;
            }
        }
        
        // 创建一个滑动手势用于拖动画面
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(myPan:)];
        
        // 创建用于付覆盖的view
        _frontView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _transitionView.frame.size.width, _transitionView.frame.size.height)];
        _frontView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myTap:)];// 单击手势，专门用于收起底层菜单，解除覆盖
        [_frontView addGestureRecognizer:tapGesture];// 添加一个单击手势用于恢复侧滑
    }
    return _tabBarControllerSingleTon;
}


#pragma mark - 自定义函数
#pragma mark 1.暴露到外部的方法
- (void)setViewControllersArray:(NSArray *)viewControllersArray
{
    _viewControllersArray = viewControllersArray;
    [self setViewControllers:@[_viewControllersArray[0]]];
    self.navDragDelegate = _viewControllersArray[0];
}

// 只有当底层view是以可以单方向滑动的方式添加时，此函数才有效
- (void)pushPreloadView
{
    [self addShadowOnSide:_direction];
    switch (_direction)
    {
        case JZRevealSideDirectionTop:
        {
            [UIView animateWithDuration:0.4 animations:^{
                _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-_sideSet);
            }];
            break;
        }
            
        case JZRevealSideDirectionLeft:
        {
            [UIView animateWithDuration:0.4 animations:^{
                _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2-_sideSet, [UIScreen mainScreen].bounds.size.height/2);
            }];
            break;
        }
            
        case JZRevealSideDirectionBottom:
        {
            [UIView animateWithDuration:0.4 animations:^{
                _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2+_sideSet);
            }];
            break;
        }
            
        case JZRevealSideDirectionRight:
        {
            [UIView animateWithDuration:0.4 animations:^{
                _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2+_sideSet, [UIScreen mainScreen].bounds.size.height/2);
            }];
            break;
        }
            
        default:
            break;
    }
    [self coverCurrentViewController];// 覆盖透明view，屏蔽当前Controller的点击事件
    _havePush = true;
}

// 还原侧滑，隐藏底部的菜单view
- (void)popPreloadView
{
    [UIView animateWithDuration:0.4 animations:^{
        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    }];
    [self uncoverCurrentViewController];// 移除覆盖在最上面的view，解除屏蔽controller的点击事件
    _havePush = false;
}

// 调用侧函数加载一个UIView放在底部，默认可以以direction方向滑动
- (void)preloadView:(UIView *)view forSide:(JZRevealSideDirection)direction withOffset:(CGFloat)offset
{
    if(_sideView != nil)
    {
        [_sideView removeFromSuperview];
    }
    [self.view insertSubview:view atIndex:0];
    _sideView = view;
    _direction = direction;
    _sideSet = offset;
    [self allowedSlide];// 添加滑动手势
}

// 视图控制器切换
- (UINavigationController *)selectedAtIndex:(NSInteger)index
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
    {
        for(UIView *view in _transitionView.subviews)
        {
            [view removeFromSuperview]; // 移除所有的view
        }
        self.viewControllers = @[_viewControllersArray[index]];
        [_transitionView addSubview:[_viewControllersArray[index] view]];
        self.navDragDelegate = _viewControllersArray[index];
        return _viewControllersArray[index];
    }
    else
    {
        [self setViewControllers:@[_viewControllersArray[index]]];
        self.selectedIndex = 0;
        self.navDragDelegate = _viewControllersArray[index];
        return _viewControllersArray[index];
    }
}


// 禁止滑动，移除滑动手势
- (void)forbidSlide
{
    // 获得所有手势
    NSArray *gestureArray = self.view.gestureRecognizers;
    for(UIGestureRecognizer *gesture in gestureArray)// 移除滑动手势
    {
        if([gesture isKindOfClass:[UIPanGestureRecognizer class]])
        {
            [self.view removeGestureRecognizer:gesture];
        }
    }
}

// 可以滑动，添加滑动手势
- (void)allowedSlide
{
    // 添加滑动手势
    if(![self haveAddPanGesture])// 如果还没有添加，保证最多添加一次
    {
        [self.view addGestureRecognizer:_panGesture];
    }
}


#pragma mark 2.仅内部使用的方法
// 侧滑拖动手势
- (void)myPan:(UIPanGestureRecognizer *)pan
{
    //手势开始
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        _isMoving = NO;
        // 记下刚接触屏幕的触点坐标
        _startPan = [pan locationInView:KEY_WINDOW];
    }
    else if(pan.state == UIGestureRecognizerStateChanged)
    {
        CGPoint movePan = [pan locationInView:KEY_WINDOW];
        if (!_isMoving && (fabs(movePan.x-_startPan.x) > 10 || fabs(movePan.y - _startPan.y) > 10))
        {
            _isMoving = YES;
        }
        if(_isMoving)
        {
            [self moveViewControllerWithOriginX:movePan.x - _startPan.x originY:movePan.y - _startPan.y];
        }
    }
    else if(pan.state == UIGestureRecognizerStateEnded)
    {
        CGPoint endPan = [pan locationInView:KEY_WINDOW];
        [self stopViewControllerWithOriginX:endPan.x - _startPan.x originY:endPan.y - _startPan.y];
    }
    else if(pan.state == UIGestureRecognizerStateCancelled)
    {
        [self stopViewControllerWithOriginX:0 originY:0];
        [self.navDragDelegate navDragCancal];
    }
}

// 移动UITabBarController的transitionView
- (void)moveViewControllerWithOriginX:(CGFloat)x originY:(CGFloat)y
{
    if(((!_havePush && x > 0 && _navDragDelegate != nil && [_navDragDelegate respondsToSelector:@selector(navDragMoveWithX:)]) || _isPanNavDragDelegate) && !_isPanSelfView)
    {
        [_navDragDelegate navDragMoveWithX:x];
        _isPanNavDragDelegate = YES;
    }
    else
    {
        _isPanSelfView = YES;
        [self addShadowOnSide:_direction];
        switch(_direction)
        {
            case JZRevealSideDirectionTop:
                if (y > - _sideSet && y < 0 && !_havePush)
                {
                    _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2+y);
                }
                if(_havePush && y > 0 && _transitionView.frame.origin.y < 0)
                {
                    _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2-_sideSet+y);
                }
                break;
                
            case JZRevealSideDirectionLeft:
                if (x < 0 && x > - _sideSet && !_havePush)
                {
                    _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2+x,[UIScreen mainScreen].bounds.size.height/2);
                }
                if(_havePush && x > 0 && _transitionView.frame.origin.x < 0)
                {
                    _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2-_sideSet+x,[UIScreen mainScreen].bounds.size.height/2);
                }
                break;
                
            case JZRevealSideDirectionBottom:
                if (y > 0 && y < _sideSet && !_havePush)
                {
                    _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2+y);
                }
                if(_havePush && y < 0 && _transitionView.frame.origin.y > 0)
                {
                    _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2+_sideSet+y);
                }
                break;
                
            case JZRevealSideDirectionRight:
                if (x > 0 && x < _sideSet && !_havePush)
                {
                    _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2+x,[UIScreen mainScreen].bounds.size.height/2);
                }
                if(_havePush && x < 0 && _transitionView.frame.origin.x > 0)
                {
                    _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2+_sideSet+x,[UIScreen mainScreen].bounds.size.height/2);
                }
                break;
                
            default:
                break;
        }
    }
}

// 结束移动UITabBarController的transitionView
- (void)stopViewControllerWithOriginX:(CGFloat)x originY:(CGFloat)y
{
    if(_isPanNavDragDelegate)
    {
        [self.navDragDelegate navDragStopWithX:x];
        _isPanNavDragDelegate = NO;
    }
    else
    {
        _isPanSelfView = NO;
        switch(_direction)
        {
            case JZRevealSideDirectionTop:
            {
                [UIView animateWithDuration:0.4 animations:^{
                    if ((_transitionView.frame.origin.y < -_sideSet/6 && !_havePush) || (_transitionView.frame.origin.y < -_sideSet*5/6 && _havePush))
                    {
                        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2-_sideSet);
                        [self coverCurrentViewController];// 覆盖透明view，屏蔽当前Controller的点击事件
                        _havePush = true;
                    }
                    else
                    {
                        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
                        [self uncoverCurrentViewController];// 移除覆盖在最上面的view，解除屏蔽controller的点击事件
                        _havePush = false;
                    }
                }];
                break;
            }
                
            case JZRevealSideDirectionLeft:
            {
                [UIView animateWithDuration:0.4 animations:^{
                    if ((_transitionView.frame.origin.x < -_sideSet/6 && !_havePush) || (_transitionView.frame.origin.x < -_sideSet*5/6 && _havePush))
                    {
                        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2-_sideSet, [UIScreen mainScreen].bounds.size.height/2);
                        [self coverCurrentViewController];// 覆盖透明view，屏蔽当前Controller的点击事件
                        _havePush = true;
                    }
                    else
                    {
                        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
                        [self uncoverCurrentViewController];// 移除覆盖在最上面的view，解除屏蔽controller的点击事件
                        _havePush = false;
                    }
                }];
                break;
            }
                
            case JZRevealSideDirectionBottom:
            {
                [UIView animateWithDuration:0.4 animations:^{
                    if ((_transitionView.frame.origin.y > _sideSet/6 && !_havePush) || (_transitionView.frame.origin.y > _sideSet*5/6 && _havePush))
                    {
                        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2+_sideSet);
                        [self coverCurrentViewController];// 覆盖透明view，屏蔽当前Controller的点击事件
                        _havePush = true;
                    }
                    else
                    {
                        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
                        [self uncoverCurrentViewController];// 移除覆盖在最上面的view，解除屏蔽controller的点击事件
                        _havePush = false;
                    }
                }];
                break;
            }
                
            case JZRevealSideDirectionRight:
            {
                [UIView animateWithDuration:0.4 animations:^{
                    if ((_transitionView.frame.origin.x > _sideSet/6 && !_havePush) || (_transitionView.frame.origin.x > _sideSet*5/6 && _havePush))
                    {
                        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2+_sideSet, [UIScreen mainScreen].bounds.size.height/2);
                        [self coverCurrentViewController];// 覆盖透明view，屏蔽当前Controller的点击事件
                        _havePush = true;
                    }
                    else
                    {
                        _transitionView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
                        [self uncoverCurrentViewController];// 移除覆盖在最上面的view，解除屏蔽controller的点击事件;
                        _havePush = false;
                    }
                }];
                break;
            }
                
            default:
                break;
        }
    }
}

// 单击手势事件响应
- (void)myTap:(UITapGestureRecognizer *)tap
{
    [self popPreloadView];
}

// 查看是够已经添加滑动手势
- (NSInteger)haveAddPanGesture
{
    NSInteger num = 0;
    NSArray *gestureArray = self.view.gestureRecognizers;
    for(UIGestureRecognizer *gesture in gestureArray)// 移除滑动手势
    {
        if([gesture isKindOfClass:[UIPanGestureRecognizer class]])
            num++;
    }
    return num;
}

// 侧滑后覆盖transtionView
- (void)coverCurrentViewController
{
    // 将一个透明的view放在最上面，屏蔽所有当前UIViewController的View上的全部触摸事件
    if(![self haveCoverViewController])// 如果还没有覆盖，保证只覆盖一次
    {
        [_transitionView insertSubview:_frontView atIndex:_transitionView.subviews.count];
        if(_isNeedToBeDark)
        {
            [UIView animateWithDuration:0.6 animations:^{
                _frontView.backgroundColor = [UIColor grayColor];
                _frontView.alpha = 0.6;
            }];
        }
    }
}

// 移除覆盖的透明view，还原Controller的点击事件响应
- (void)uncoverCurrentViewController
{
    // 将_frontView从transtionView上移除
    NSArray *arr = _transitionView.subviews;
    for(UIView *view in arr)
    {
        if(view == _frontView)
        {
            if(!_isNeedToBeDark)
            {
                [view removeFromSuperview];
            }
            else
            {
                [UIView animateWithDuration:0.6 animations:^{
                    _frontView.backgroundColor = [UIColor clearColor];
                } completion:^(BOOL finished) {
                    [view removeFromSuperview];
                }];
            }
        }
    }
}

// 检测是否已经屏蔽点击交互能力
- (NSInteger)haveCoverViewController
{
    NSInteger num = 0;
    NSArray *arr = _transitionView.subviews;
    for(UIView *view in arr)
    {
        if(view == _frontView)
        {
            num++;
        }
    }
    return num;
}

// 添加阴影
- (void)addShadowOnSide:(JZRevealSideDirection)direction
{
    if(_isNeedShadow)
    {
        // 配置侧滑阴影
        _transitionView.layer.shadowOpacity = 0.75f;
        _transitionView.layer.shadowRadius = 10.0f;
        _transitionView.layer.shadowColor = [UIColor blackColor].CGColor;
        _transitionView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
        _transitionView.clipsToBounds = NO;
        switch(direction)
        {
            case JZRevealSideDirectionTop:
                _transitionView.layer.shadowOffset = CGSizeMake(0, 10);
                break;
                
            case JZRevealSideDirectionLeft:
                _transitionView.layer.shadowOffset = CGSizeMake(10, 0);
                break;
                
            case JZRevealSideDirectionBottom:
                _transitionView.layer.shadowOffset = CGSizeMake(0, -10);
                break;
                
            case JZRevealSideDirectionRight:
                _transitionView.layer.shadowOffset = CGSizeMake(-10, 0);
                break;
                
            default:
                break;
        }
    }
    else
    {
        _transitionView.layer.shadowOpacity = 0;
        _transitionView.layer.shadowRadius = 0;
    }
}

- (void)tabbarDealloc
{
    _tabBarControllerSingleTon = nil;
}

- (void)dealloc
{
    _navDragDelegate = nil;
    for(UIView *view in _transitionView.subviews)
    {
        [view removeFromSuperview];
    }
    for(UINavigationController *nav in _viewControllersArray)
    {
        [nav popToRootViewControllerAnimated:NO];
    }
    _viewControllersArray = nil;
    _sideView = nil;
    for(UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
    [self forbidSlide]; // 移除手势
    _panGesture = nil;
    [_frontView removeFromSuperview];
    _frontView = nil;
}

@end










