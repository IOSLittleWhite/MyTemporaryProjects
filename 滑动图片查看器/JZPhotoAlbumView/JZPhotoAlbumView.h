//
//  JZPhotoAlbumView.h
//  JZBPM
//
//  Created by JZ_Stone on 14-10-14.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZPhotoAlbumViewCell.h"

@class JZPhotoAlbumView;
/// 定义一种结构体，用来表示区间。表示一个 从 几到几 的概念
typedef struct _JZRange
{
    NSInteger start;
    NSInteger end;
} JZRange;

/**
 * @brief 创建结构体 JZRange，结构体中保存start，end
 * @param start 范围开始
 * @param end   范围结束
 * @return 返回 该范围
 * @note eg. JZRangeMake(0,5) 则返回 0~5
 */
NS_INLINE JZRange JZRangeMake(NSInteger start, NSInteger end)
{
    JZRange range;
    range.start = start;
    range.end = end;
    return range;
}

/**
 * @brief 该int 数 是否在 JZRange区间内
 * @param r 整形区间
 * @param i 要比较的数
 * @return i在区间 r内，返回YES；否则，返回NO
 */
NS_INLINE BOOL InRange(JZRange r,NSInteger i)
{
    return (r.start <= i) && (r.end >= i);
}

/**
 * @brief JZphotoAlbumView 在滑动过程中表示向左滑还是向右滑
 * @enum JZDirectionType
 * @constant   JZDirectionLeft   表示向左滑
 * @constant   JZDirectionRight  表示向右滑
 */
typedef NS_ENUM(NSInteger, JZDirectionType)
{
    JZDirectionTypeLeft,
    JZDirectionTypeRight
};

@protocol JZPhotoAlbumViewDataSource <NSObject>

@optional
/**
 * @brief 共有多少列
 * @param photoAlbumView 当前所在的photoAlbumView
 */
- (NSInteger)numberOfColumnsInPhotoAlbumView:(JZPhotoAlbumView *)photoAlbumView;

/**
 * @brief 这一列有多宽，根据有多宽，算出需要加载多少个
 * @param index  当前所在列
 */
- (CGFloat)widthForColumnAtIndex:(NSInteger)index;

/**
 * @brief 每列 显示什么
 * @param photoAlbumView 当前所在的photoAlbumView
 * @param index  当前所在列
 * @return  当前所要展示的页
 */
- (JZPhotoAlbumViewCell *)photoAlbumView:(JZPhotoAlbumView *)photoAlbumView viewForColumnAtIndex:(NSInteger)index;

@end


@protocol JZPhotoAlbumViewDelegate <NSObject>

@optional
/**
 *  点击某个Cell的回调
 *
 *  @param photoAlbumView 当前所在的photoAlbumView
 *  @param index          当前所在列
 */
- (void)photoAlbumView:(JZPhotoAlbumView *)photoAlbumView didSelectedCellAtIndex:(NSInteger)index;

/**
 *  当前正在显示的view的下标
 */
- (void)photoAlbumView:(JZPhotoAlbumView *)photoAlbumView didShowCellAtIndex:(NSInteger)index;

@end


@interface UIScrollView (Rect)

- (CGRect)visibleRect;

@end

@interface JZPhotoAlbumView : UIView<NSCoding, UIScrollViewDelegate>

@property (nonatomic, weak) id<JZPhotoAlbumViewDataSource> dataSource;
@property (nonatomic, weak) id<JZPhotoAlbumViewDelegate> delegate;
@property (nonatomic, assign) BOOL isShowProgress;

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadDataAtIndex:(NSInteger)index;

- (void)deleteCurrentView;

-(void)photoAlbumViewCellDidSelected:(JZPhotoAlbumViewCell *)cell;

@end







