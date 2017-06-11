//
//  JZTabBarController.h
//  JZBPM_MI
//
//  Created by JZ_Stone on 14-7-3.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NavigationDragBackDelegate <NSObject>

@required
- (void)navDragMoveWithX:(CGFloat)x;
- (void)navDragStopWithX:(CGFloat)x;
- (void)navDragCancal;

@end


// 侧滑方向
enum {
    JZRevealSideDirectionTop = 1,
    JZRevealSideDirectionLeft = 2,
    JZRevealSideDirectionBottom = 3,
    JZRevealSideDirectionRight = 4,
    JZRevealSideDirectionNone = 0,
};
typedef NSUInteger JZRevealSideDirection;


/**
 * 可以支持四个方向的单一侧滑
 */
@interface JZTabBarController : UITabBarController

@property (nonatomic, weak) id<NavigationDragBackDelegate> navDragDelegate;

/**
 * 当要加入的viewController多余5个时用这个属性
 */
@property (nonatomic, strong) NSArray *viewControllersArray;

/**
 * 侧滑时是否需要阴影
 */
@property (nonatomic, assign) BOOL isNeedShadow;

/**
 * 侧滑后是否需要让滑出去部分变暗
 */
@property (nonatomic, assign) BOOL isNeedToBeDark;

/**
 * 单列设计，实现共享tabBar
 */
+ (JZTabBarController *)sharedTabBarController;

/**
 * 只有当底层view是以可以单方向滑动的方式添加时，此函数才有效
 */
- (void)pushPreloadView;

/**
 * 还原侧滑，隐藏底部的菜单view
 */
- (void)popPreloadView;

/**
 * 调用侧函数加载一个UIView放在底部，默认可以以direction方向滑动
 */
- (void)preloadView:(UIView *)view forSide:(JZRevealSideDirection)direction withOffset:(CGFloat)offset;

/**
 * 视图控制器切换，当要加入的viewController多余5个时用这个属性
 */
- (UINavigationController *)selectedAtIndex:(NSInteger)index;

/**
 * 禁止滑动，移除滑动手势
 */
- (void)forbidSlide;

/**
 * 可以滑动，添加滑动手势
 */
- (void)allowedSlide;

/**
 *  释放tabbar单列
 */
- (void)tabbarDealloc;


@end







