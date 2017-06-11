//
//  HMHeadScrollView.h
//  JZBPM
//
//  Created by JZ_Stone on 15/11/20.
//  Copyright © 2015年 广州市九章信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HMHeadScrollViewSeletedStyle)
{
    HMHeadScrollViewSeletedStyleUnderLine,     // 选中以下划线标记
    HMHeadScrollViewSeletedStyleBackSquare,    // 选中以方形底色块标记
    HMHeadScrollViewSeletedStyleBackCircle     // 选中以圆形底色块标记
};

@protocol HMHeadScrollViewDataSource;
@protocol HMHeadScrollViewDelegate;

@interface HMHeadScrollView : UIView

/**
 *  delegate
 */
@property (nonatomic, weak) id<HMHeadScrollViewDelegate> delegate;

/**
 *  dataSource
 */
@property (nonatomic, weak) id<HMHeadScrollViewDataSource> dataSource;

/**
 *  头部背景颜色
 */
@property (nonatomic, strong) UIColor *headBckgroundColor;

/**
 *  内容区背景颜色
 */
@property (nonatomic, strong) UIColor *contentBackgroundColor;

/**
 *  选中标记块的颜色
 */
@property (nonatomic, strong) UIColor *selectedMarkViewColor;

/**
 *  头部背景图
 */
@property (nonatomic, strong) UIImage *headBackgroundImage;

/**
 *  内容区背景图
 */
@property (nonatomic, strong) UIImage *contentBackgroundImage;

/**
 *  头部和内容区的分割线
 */
@property (nonatomic, strong) UIView *separatorView;

/**
 *  当前选中的下标
 */
@property (nonatomic, assign, readonly) NSInteger selectedIndex;

/**
 *  选中的风格
 */
@property (nonatomic, assign) HMHeadScrollViewSeletedStyle selectedStyle;

@end





#pragma mark - protocol - DataSource
@protocol HMHeadScrollViewDataSource <NSObject>
@optional
// 头部高度
- (CGFloat)headHeightForHeadScrollView:(HMHeadScrollView *)headScrollView;

// 头部各个tab的宽度
- (CGFloat)headScrollView:(HMHeadScrollView *)headScrollView widthForHeadCellAtIndex:(NSInteger)index;

@required
// 页数
- (NSInteger)numberOfTabsForHeadScrollView:(HMHeadScrollView *)headScrollView;

// 头部各个tab的视图
- (UIView *)headScrollView:(HMHeadScrollView *)headScrollView headCellViewForHeadAtIndex:(NSInteger)index;

// 每个内容页面的视图
- (UIView *)headScrollView:(HMHeadScrollView *)headScrollView contentCellViewForContentAtIndex:(NSInteger)index;

@end


#pragma mark - protocol - Delegate
@protocol HMHeadScrollViewDelegate <NSObject>
@optional
- (void)headScrollView:(HMHeadScrollView *)headScrollView didSeletTabAtIndex:(NSInteger)index;

@end















