//
//  JZPhotoAlbumView.m
//  JZBPM
//
//  Created by JZ_Stone on 14-10-14.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import "JZPhotoAlbumView.h"
#import "JZScrollView.h"
#import "JZConfigFactor.h"
#import "JZCommonUtil.h"

@implementation UIScrollView (Rect)

- (CGRect)visibleRect
{
    CGRect rect;
    rect.origin = self.contentOffset;
    rect.size = self.bounds.size;
    return rect;
}

@end

@implementation JZPhotoAlbumView
{
    /// ListCell 个数
    NSInteger _columns;
    /// 每个JZPhotoAlbumViewCell 的高度
    CGFloat _height;
    /// 所有的JZPhotoAlbumViewCell 的frame
    NSMutableArray *_columnRects;
    /// 可见的column范围
    JZRange _visibleRange;
    /// scrollView 的可见区域
    CGRect _visibleRect;
    /// 可见的JZPhotoAlbumViewCell;
    NSMutableArray *_visibleListCells;
    /// 可重用的ListCells {identifier:[cell1,cell2]}
    NSMutableDictionary *_reusableListCells;
    
    JZScrollView *_scrollView;
    UIView *_currentView;
    UILabel *_prosessLabel; // 显示当前为第几张图片
}

- (id)init
{
    if(self = [super init])
    {
        _scrollView = [[JZScrollView alloc] init];
        _scrollView.contentOffset = CGPointZero;
        _scrollView.delegate = self;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        
        _prosessLabel = [[UILabel alloc] init];
        _prosessLabel.font = [UIFont systemFontOfSize:20];
        _prosessLabel.textColor = [UIColor whiteColor];
        _prosessLabel.textAlignment = NSTextAlignmentCenter;
        _prosessLabel.alpha = 0.0f;
        _prosessLabel.backgroundColor = [UIColor clearColor];
        _prosessLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _prosessLabel.layer.shadowOffset = CGSizeMake(1, 1);
        _prosessLabel.layer.shadowOpacity = 0.5;
        [self addSubview:_prosessLabel];
        
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        
        _isShowProgress = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _prosessLabel.frame = CGRectMake((frame.size.width-80)/2, frame.size.height-80, 80, 40);
    _height = frame.size.height;
}

- (void)setIsShowProgress:(BOOL)isShowProgress
{
    _isShowProgress = isShowProgress;
    if(!isShowProgress)
    {
        [_prosessLabel removeFromSuperview];
        _prosessLabel = nil;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.pagingEnabled = NO;
        _scrollView.bounces = YES;
    }
}

- (void)setDataSource:(id<JZPhotoAlbumViewDataSource>)dataSource
{
    _dataSource = dataSource;
    if([self.delegate respondsToSelector:@selector(photoAlbumView:didShowCellAtIndex:)])
    {
        [self.delegate photoAlbumView:self didShowCellAtIndex:0];
    }
    [self loadDataAtIndex:0];
}

- (void)reloadDataAtIndex:(NSInteger)index
{
    while(_visibleListCells.count > 0)
    {
        [self inqueueReusableWithView:[_visibleListCells firstObject]];
    }
    if([self.delegate respondsToSelector:@selector(photoAlbumView:didShowCellAtIndex:)])
    {
        [self.delegate photoAlbumView:self didShowCellAtIndex:index];
    }
    [self loadDataAtIndex:index];
}

- (void)deleteCurrentView
{
    NSInteger index = _currentView.tag;
    if(index == _columns-1) // 如果当前浏览到最后一张且要删除
    {
        index = _columns - 2;
    }
    if([self.delegate respondsToSelector:@selector(photoAlbumView:didShowCellAtIndex:)])
    {
        [self.delegate photoAlbumView:self didShowCellAtIndex:index];
    }
    [self loadDataAtIndex:index];
}

- (void)loadDataAtIndex:(NSInteger)index
{
    NSInteger tempIndex = index;
    if([_dataSource respondsToSelector:@selector(numberOfColumnsInPhotoAlbumView:)])
    {
        [_columnRects removeAllObjects];
        _columns = [_dataSource numberOfColumnsInPhotoAlbumView:self];
        if (_columns <= 0)
        {
            return;
        }
        CGFloat width = _height;
        CGFloat left = 0;
        _visibleRange = JZRangeMake(0, 0);
        _columnRects = [NSMutableArray arrayWithCapacity:_columns];
        for(NSInteger index = 0; index < _columns; index ++)
        {
            if([_dataSource respondsToSelector:@selector(widthForColumnAtIndex:)])
            {
                width = [_dataSource widthForColumnAtIndex:index];
            }
            CGRect rect = CGRectMake(left, 0, width, _height);
            [_columnRects addObject:NSStringFromCGRect(rect)];
            left += width;
        }
        _scrollView.contentSize = CGSizeMake(left, _height);
    }
    if(!_visibleListCells)
    {
        _visibleListCells = [NSMutableArray arrayWithCapacity:2];
    }
    _visibleRange.start = index;
    CGFloat left = index*SCREEN_WIDTH;
    while(left <= (index+1)*SCREEN_WIDTH && tempIndex <= _columns-1)
    {
        CGRect frame = CGRectFromString([_columnRects objectAtIndex:tempIndex]);
        [self requestCellWithIndex:tempIndex direction:JZDirectionTypeLeft];
        left += frame.size.width;
        if (left <= (index+1)*SCREEN_WIDTH)
        {
            tempIndex++;
        }
    }
    _currentView = [_visibleListCells objectAtIndex:0]; // 初始时显示第一张图片
    _visibleRange.end = tempIndex<_columns?tempIndex:(_columns-1);
    _scrollView.contentOffset = CGPointMake(index * SCREEN_WIDTH, 0);
}

- (JZPhotoAlbumViewCell *)requestCellWithIndex:(NSInteger)index direction:(JZDirectionType)direction
{
    CGRect frame = CGRectFromString([_columnRects objectAtIndex:index]);
    JZPhotoAlbumViewCell *cell = [_dataSource photoAlbumView:self viewForColumnAtIndex:index];
    cell.frame = frame;
    cell.tag = index;
    [_scrollView addSubview:cell];
    if(direction == JZDirectionTypeLeft)
    {
        [_visibleListCells addObject:cell];
    }
    else if(direction == JZDirectionTypeRight)
    {
        [_visibleListCells insertObject:cell atIndex:0];
    }
    return cell;
}

- (void)reLayoutSubViewsWithOffset:(CGFloat)offset
{
    @try {
        NSInteger start = _visibleRange.start;
        NSInteger end = _visibleRange.end;
        CGRect frame = CGRectFromString([_columnRects objectAtIndex:start]);
        CGRect frame1 = CGRectFromString([_columnRects objectAtIndex:end]);
        // 向左滑动
        if(offset > 0)
        {
            // 判断如果 可见区域的第一个移除区域外，则放进 可复用池里面。允许可复用
            if((_visibleRect.origin.x) >= (frame.origin.x + frame.size.width))
            {
                JZPhotoAlbumViewCell *cell = (JZPhotoAlbumViewCell *)[_visibleListCells firstObject];
                [self inqueueReusableWithView:cell];
                start += 1;
                _visibleRange.start = start;
            }
            // 如果最后一个的末尾被滚进区域，则加载下一个
            if((_visibleRect.origin.x + _visibleRect.size.width) >= (frame1.origin.x + frame1.size.width))
            {
                end += 1;
                if(end < _columns)
                {
                    [self requestCellWithIndex:end direction:JZDirectionTypeLeft];
                    _visibleRange.end = end;
                }
            }
        }
        // 向右滑动
        else
        {
            // 判断如果 可见区域的最后一个移除区域外，则放进 可复用池里面。允许可复用
            if( frame1.origin.x >= (_visibleRect.origin.x + _visibleRect.size.width) )
            {
                JZPhotoAlbumViewCell * cell = (JZPhotoAlbumViewCell *) [_visibleListCells lastObject];
                [self inqueueReusableWithView:cell];
                end -= 1;
                _visibleRange.end = end;
                
            }
            if(frame.origin.x >= _visibleRect.origin.x)
            {
                start -= 1;
                if (start >= 0)
                {
                    [self requestCellWithIndex:start direction:JZDirectionTypeRight];
                    _visibleRange.start = start;
                }
            }
        }
    }
    @catch (NSException *exception) {
        JZLog(@"\nerror: %@\n%@", exception, [exception callStackSymbols]);
    };
}

/// Cell 的复用，从复用池取
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    JZPhotoAlbumViewCell * cell = nil;
    NSMutableArray * reuseCells = [_reusableListCells objectForKey:identifier];
    if([reuseCells count] > 0)
    {
        cell = [reuseCells objectAtIndex:0];
        [reuseCells removeObject:cell]; // 从复用池移除
    }
    return cell;
}

// 添加到复用池
- (void)inqueueReusableWithView:(JZPhotoAlbumViewCell *)reuseView
{
    NSString *identifier = reuseView.reuseIdentifier;
    if(!_reusableListCells)
    {
        _reusableListCells = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    NSMutableArray * cells = [_reusableListCells valueForKey:identifier];
    if (!cells)
    {
        cells  = [[NSMutableArray alloc] initWithCapacity:1];
        [_reusableListCells setValue:cells forKey:identifier];
    }
    [cells addObject:reuseView];
    [_visibleListCells removeObject:reuseView];
    [reuseView reFreshUI];
    [reuseView removeFromSuperview];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(_isShowProgress)
    {
        CGFloat offSet = scrollView.contentOffset.x;
        _prosessLabel.text = [NSString stringWithFormat:@"%ld/%ld", (NSInteger)offSet/(NSInteger)SCREEN_WIDTH + 1, _columns];
        [self bringSubviewToFront:_prosessLabel];
        [UIView animateWithDuration:0.4 animations:^{
            _prosessLabel.alpha = 1.0;
        }];
    }
}

// 正在滚动查看图片
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect tempRect = [scrollView visibleRect]; // 获取当前偏移量的信息
    CGFloat offsetX = tempRect.origin.x - _visibleRect.origin.x; // 本次滚动的量
    _visibleRect = tempRect; // 设置下一次滚动的起点
    
    NSInteger index = tempRect.origin.x / SCREEN_WIDTH;
    for(JZPhotoAlbumViewCell *cell in _visibleListCells) // 找出当前正在显示的view
    {
        if(cell.tag == index)
        {
            _currentView = cell;
            break;
        }
    }
    
    [self reLayoutSubViewsWithOffset:offsetX];
}

// 显示当前在看第几张
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_isShowProgress)
    {
        CGFloat offSet = scrollView.contentOffset.x;
        _prosessLabel.text = [NSString stringWithFormat:@"%ld/%ld", (NSInteger)offSet/(NSInteger)SCREEN_WIDTH + 1, _columns];
        if([self.delegate respondsToSelector:@selector(photoAlbumView:didShowCellAtIndex:)])
        {
            [self.delegate photoAlbumView:self didShowCellAtIndex:(NSInteger)offSet/(NSInteger)SCREEN_WIDTH];
        }
        [UIView animateWithDuration:1.0 animations:^{
            _prosessLabel.alpha = 0.0f;
        }];
    }
}


#pragma mark - Cell selected event
-(void)photoAlbumViewCellDidSelected:(JZPhotoAlbumViewCell *)cell
{
    if([self.delegate respondsToSelector:@selector(photoAlbumView:didSelectedCellAtIndex:)])
    {
        [self.delegate photoAlbumView:self didSelectedCellAtIndex:cell.tag];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesEnded:touches withEvent:event];
}

@end

















