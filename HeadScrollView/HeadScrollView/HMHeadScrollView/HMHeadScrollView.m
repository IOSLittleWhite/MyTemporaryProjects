//
//  HMHeadScrollView.m
//  JZBPM
//
//  Created by JZ_Stone on 15/11/20.
//  Copyright © 2015年 广州市九章信息科技有限公司. All rights reserved.
//

#import "HMHeadScrollView.h"
#import "Masonry.h"

@interface HMHeadScrollView () <UIScrollViewDelegate>
{
    CGFloat _headHeight;
    CGFloat _headWidth;
    CGFloat _contentHeight;
    NSInteger _tabsCount;
    NSMutableArray *_tabButtons;
    
    CGFloat _lastOffset;
    BOOL _draging;
    BOOL _haveSetMarkColor;
}

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *headScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *selectedMarkView;
@property (nonatomic, assign, readonly) CGSize visibleSize;

@end

@implementation HMHeadScrollView

- (id)init
{
    if(self = [super init])
    {
        [self addSubview:self.headView];
        [self addSubview:self.contentView];
        _selectedStyle = HMHeadScrollViewSeletedStyleUnderLine;
        _tabButtons = [NSMutableArray array];
        _lastOffset = 0;
        _headHeight = 50;
        _headWidth = 50;
        _haveSetMarkColor = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self addSubview:self.headView];
        [self addSubview:self.contentView];
        _selectedStyle = HMHeadScrollViewSeletedStyleUnderLine;
        _tabButtons = [NSMutableArray array];
        _lastOffset = 0;
        _headHeight = 50;
        _headWidth = 50;
        _haveSetMarkColor = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if([self.dataSource respondsToSelector:@selector(headHeightForHeadScrollView:)])
    {
        _headHeight = [self.dataSource headHeightForHeadScrollView:self];
    }
    _tabsCount = [self.dataSource numberOfTabsForHeadScrollView:self];
    _contentHeight = self.visibleSize.height - _headHeight;
    
    self.headView.frame = CGRectMake(0, 0, self.visibleSize.width, _headHeight);
    self.headScrollView.frame = CGRectMake(0, 0, self.visibleSize.width, _headHeight);
    self.contentView.frame = CGRectMake(0, _headHeight, self.visibleSize.width, _contentHeight);
    
    CGFloat wholeHeadWidth = 0;
    for(NSInteger i=0; i<_tabsCount; i++)
    {
        CGFloat width = _headWidth;
        if([self.dataSource respondsToSelector:@selector(headScrollView:widthForHeadCellAtIndex:)])
        {
            width = [self.dataSource headScrollView:self widthForHeadCellAtIndex:i];
        }
        UIView *headCellView = [self.dataSource headScrollView:self headCellViewForHeadAtIndex:i];
        UIView *contentCellView = [self.dataSource headScrollView:self contentCellViewForContentAtIndex:i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(wholeHeadWidth, 0, width, _headHeight);
        button.backgroundColor = [UIColor clearColor];
        button.tag = i;
        [button addTarget:self action:@selector(selectTabClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.headScrollView addSubview:button];
        [_tabButtons addObject:button];
        
        CGFloat headWidth = width;
        if(headCellView.frame.size.width < headWidth)
        {
            headWidth = headCellView.frame.size.width;
        }
        CGFloat headHeight = _headHeight;
        if(headCellView.frame.size.height < headHeight)
        {
            headHeight = headCellView.frame.size.height;
        }
        headCellView.frame = CGRectMake((width-headWidth)/2, (_headHeight-headHeight)/2, headWidth, headHeight);
        [button addSubview:headCellView];
        
        contentCellView.frame = CGRectMake(i*self.visibleSize.width, 0, self.visibleSize.width, _contentHeight);
        [self.contentScrollView addSubview:contentCellView];
        
        wholeHeadWidth += width;
    }
    self.headScrollView.contentSize = CGSizeMake(wholeHeadWidth, _headHeight);
    self.headScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.contentScrollView.contentSize = CGSizeMake(self.visibleSize.width*_tabsCount, _contentHeight);
    
    if(wholeHeadWidth<self.visibleSize.width)
    {
        self.headScrollView.frame = CGRectMake((self.visibleSize.width-wholeHeadWidth)/2, 0, wholeHeadWidth, _headHeight);
    }
    
    [self didSelectedAtIndex:0];
}


#pragma mark - event response
- (void)selectTabClicked:(UIButton *)btn
{
    btn.userInteractionEnabled = NO;
    [self didSelectedAtIndex:btn.tag];
    btn.userInteractionEnabled = YES;
}

- (void)didSelectedAtIndex:(NSInteger)index
{
    CGFloat offset = self.visibleSize.width * index;
    [self.contentScrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    if([self.delegate respondsToSelector:@selector(headScrollView:didSeletTabAtIndex:)])
    {
        [self.delegate headScrollView:self didSeletTabAtIndex:index];
    }
    
    // 设置tab选中状态
    UIButton *button = _tabButtons[index];
    CGRect frame = button.frame;
    [self.selectedMarkView.layer setCornerRadius:0.0f];
    switch (self.selectedStyle)
    {
        case HMHeadScrollViewSeletedStyleBackSquare:
        {
            self.selectedMarkView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, _headHeight);
        }
            break;
            
        case HMHeadScrollViewSeletedStyleBackCircle:
        {
            self.selectedMarkView.frame = CGRectMake(0, 0, _headHeight-10, _headHeight-10);
            self.selectedMarkView.center = button.center;
            [self.selectedMarkView.layer setCornerRadius:(_headHeight-10)/2];
        }
            break;
            
        case HMHeadScrollViewSeletedStyleUnderLine:
        {
            self.selectedMarkView.frame = CGRectMake(frame.origin.x, _headHeight-3, frame.size.width, 3);
        }
            break;
            
        default:
            break;
    }
    
    // 调整选中tab在可视区的位置，尽量居中
    offset = self.headScrollView.contentOffset.x;
    CGRect rect = [self.selectedMarkView.superview convertRect:self.selectedMarkView.frame toView:self];
    CGFloat distance = rect.origin.x+rect.size.width/2-self.visibleSize.width/2; // 当前选中tab的中心离可视区域中心的距离
    if(distance > 0) // 选中的tab在屏幕偏右
    {
        CGFloat restDistance = self.headScrollView.contentSize.width-self.headScrollView.frame.size.width-offset; // 右边剩余可以滚动区域
        if(restDistance >= distance)
        {
            [self.headScrollView setContentOffset:CGPointMake(offset+distance, 0) animated:YES];
        }
        else if(restDistance > 0)
        {
            [self.headScrollView setContentOffset:CGPointMake(offset+restDistance, 0) animated:YES];
        }
    }
    else
    {
        if(offset >= -distance)
        {
            [self.headScrollView setContentOffset:CGPointMake(offset+distance, 0) animated:YES];
        }
        else if(offset > 0)
        {
            [self.headScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
    _selectedIndex = index;
    _draging = NO;
    _lastOffset = self.visibleSize.width*index;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = self.contentScrollView.contentOffset.x/self.visibleSize.width;
    [self didSelectedAtIndex:index];
    _lastOffset = scrollView.contentOffset.x;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _draging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_draging)
    {
        UIButton *currentButton = _tabButtons[_selectedIndex];
        UIButton *nextButton = currentButton;
        CGRect frame = currentButton.frame;
        if(self.selectedStyle == HMHeadScrollViewSeletedStyleBackCircle)
        {
            frame.origin.x += (frame.size.width-(frame.size.height-10))/2;
            frame.origin.y = frame.origin.y + 5;
            frame.size.width = frame.size.height - 10;
            frame.size.height = frame.size.height - 10;
        }
        else if(self.selectedStyle == HMHeadScrollViewSeletedStyleUnderLine)
        {
            frame.origin.y = frame.size.height-3;
            frame.size.height = 3;
        }
        // 移动距离倍率换算，调整selectedMark的x坐标
        CGFloat distance = scrollView.contentOffset.x-_lastOffset; // 本次滑动距离
        if(distance > 0)
        {
            if(_selectedIndex < _tabButtons.count-1)
            {
                nextButton = _tabButtons[_selectedIndex+1];
            }
        }
        else
        {
            if(_selectedIndex > 0)
            {
                nextButton = _tabButtons[_selectedIndex-1];
            }
        }
        CGFloat width = currentButton.frame.size.width/2+nextButton.frame.size.width/2; // 相邻两个tab间距
        CGFloat scale = width/self.visibleSize.width;
        CGFloat realDistance = distance*scale; // content区引发head区滚动的实际距离
        frame.origin.x += realDistance; // 得到markView的新的x坐标
        
        // 调整selectedMarkView的宽度
        if(self.selectedStyle != HMHeadScrollViewSeletedStyleBackCircle)
        {
            CGFloat widthGap = nextButton.frame.size.width-currentButton.frame.size.width; // 宽度变化的目标值
            CGFloat widthScale = widthGap/width; // 算出宽的调整相对于移动距离的比例
            if(realDistance > 0)
            {
                frame.size.width += realDistance*widthScale;
                frame.origin.x -= realDistance*widthScale/2;
            }
            else
            {
                frame.size.width -= realDistance*widthScale;
                frame.origin.x += realDistance*widthScale/2;
            }
        }
        
        self.selectedMarkView.frame = frame;
    }
}


#pragma mark - getters
- (UIView *)headView
{
    if(!_headView)
    {
        _headView = [[UIView alloc] init];
        _headView.backgroundColor = [UIColor clearColor];
        _headView.clipsToBounds = YES;
        
        [_headView addSubview:self.headScrollView];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithRed:0xd9/255.0 green:0xd9/255.0 blue:0xd9/255.0 alpha:1.0f];
        [_headView addSubview:line];
        self.separatorView = line;
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_headView);
            make.left.equalTo(_headView);
            make.right.equalTo(_headView);
            make.height.mas_equalTo(0.5);
        }];
    }
    return _headView;
}

- (UIScrollView *)headScrollView
{
    if(!_headScrollView)
    {
        _headScrollView = [[UIScrollView alloc] init];
        _headScrollView.backgroundColor = [UIColor clearColor];
        _headScrollView.showsHorizontalScrollIndicator = NO;
        _headScrollView.showsVerticalScrollIndicator = NO;
        
        [_headScrollView addSubview:self.selectedMarkView];
    }
    return _headScrollView;
}

- (UIView *)contentView
{
    if(!_contentView)
    {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        
        [_contentView addSubview:self.contentScrollView];
        [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_contentView);
            make.size.equalTo(_contentView);
        }];
    }
    return _contentView;
}

- (UIScrollView *)contentScrollView
{
    if(!_contentScrollView)
    {
        _contentScrollView = [[UIScrollView alloc] init];
        _contentScrollView.backgroundColor = [UIColor clearColor];
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.delegate = self;
        _contentScrollView.pagingEnabled = YES;
    }
    return _contentScrollView;
}

- (UIView *)selectedMarkView
{
    if(!_selectedMarkView)
    {
        _selectedMarkView = [[UIView alloc] init];
        _selectedMarkView.backgroundColor = [UIColor redColor];
        _selectedMarkView.clipsToBounds = YES;
    }
    return _selectedMarkView;
}

- (CGSize)visibleSize
{
    return self.frame.size;
}


#pragma mark - setters
- (void)setHeadBckgroundColor:(UIColor *)headBckgroundColor
{
    self.headView.backgroundColor = headBckgroundColor;
}

- (void)setHeadBackgroundImage:(UIImage *)headBackgroundImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = headBackgroundImage;
    [self.headView addSubview:imageView];
    [self.headView sendSubviewToBack:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.headView);
        make.size.equalTo(self.headView);
    }];
}

- (void)setContentBackgroundColor:(UIColor *)contentBackgroundColor
{
    self.contentView.backgroundColor = contentBackgroundColor;
}

- (void)setContentBackgroundImage:(UIImage *)contentBackgroundImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = contentBackgroundImage;
    [self.contentView addSubview:imageView];
    [self.contentView sendSubviewToBack:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.size.equalTo(self.contentView);
    }];
}

- (void)setSeparatorView:(UIView *)separatorView
{
    if(separatorView)
    {
        [self.headView addSubview:separatorView];
        [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.headView);
            make.left.equalTo(self.headView);
            make.right.equalTo(self.headView);
            make.height.mas_equalTo(0.5);
        }];
    }
    else
    {
        [self.separatorView removeFromSuperview];
        self.separatorView = nil;
    }
}

- (void)setSelectedMarkViewColor:(UIColor *)selectedMarkViewColor
{
    _haveSetMarkColor = YES;
    _selectedMarkViewColor = selectedMarkViewColor;
    self.selectedMarkView.backgroundColor = selectedMarkViewColor;
}

- (void)setSelectedStyle:(HMHeadScrollViewSeletedStyle)selectedStyle
{
    _selectedStyle = selectedStyle;
    [self didSelectedAtIndex:_selectedIndex];
    if(!_haveSetMarkColor)
    {
        self.selectedMarkView.backgroundColor = [UIColor colorWithRed:0xef/255.0 green:0xef/255.0 blue:0xf4/255.0 alpha:1.0f];
        if(_selectedStyle == HMHeadScrollViewSeletedStyleUnderLine)
        {
            self.selectedMarkView.backgroundColor = [UIColor redColor];
        }
    }
}

@end
















