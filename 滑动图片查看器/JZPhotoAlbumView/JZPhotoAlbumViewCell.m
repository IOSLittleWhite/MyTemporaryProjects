//
//  JZPhotoAlbumViewCell.m
//  JZBPM
//
//  Created by JZ_Stone on 14-10-14.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import "JZPhotoAlbumViewCell.h"
#import "JZScrollView.h"
#import "JZPhotoAlbumView.h"

@implementation JZPhotoAlbumViewCell
{
    CGPoint _oldPoint;
    CGFloat _oldWidth;
    CGFloat _oldHeight;
    
    JZScrollView *_scrollView;
    BOOL _tapClicks;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super init])
    {
        _reuseIdentifier = reuseIdentifier;
        _maximumZoomScale = 2.5f;
        _minimumZoomScale = 0.5f;
        _scrollView = [[JZScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.multipleTouchEnabled = YES; // 开启多点触控
        _scrollView.maximumZoomScale = _maximumZoomScale; // 最大放大倍数
        _scrollView.minimumZoomScale = _minimumZoomScale; // 最小缩小比例
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.bouncesZoom = YES;
        [self addSubview:_scrollView];
        
        self.imageView = [[JZImageViewAutoFitImageSize alloc] initWithFrame:frame];
        [_scrollView addSubview:self.imageView];
        
        _oldPoint = CGPointMake(frame.size.width/2, frame.size.height/2);
        _oldWidth = frame.size.width;
        _oldHeight = frame.size.height;
        
        self.backgroundColor = [UIColor blackColor];
        
        _isNeedBeZoom = YES;
        _tapClicks = NO;
    }
    return self;
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
    _maximumZoomScale = maximumZoomScale;
    _scrollView.maximumZoomScale = _maximumZoomScale;
}

- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale
{
    _minimumZoomScale = minimumZoomScale;
    _scrollView.minimumZoomScale = _minimumZoomScale; 
}

- (void)setIsNeedBeZoom:(BOOL)isNeedBeZoom
{
    _isNeedBeZoom = isNeedBeZoom;
    if(!_isNeedBeZoom)
    {
        _scrollView.multipleTouchEnabled = NO;
        _scrollView.userInteractionEnabled = NO;
    }
}

- (void)setIsAutoFitImageSize:(BOOL)isAutoFitImageSize
{
    if(!isAutoFitImageSize)
    {
        self.imageView.isAutoFitImageSize = NO;
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width-5, self.imageView.frame.size.height);
    }
}

- (void)setIsNeedTapZoom:(BOOL)isNeedTapZoom
{
    _isNeedTapZoom = isNeedTapZoom;
    if(isNeedTapZoom)
    {
        //单击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        //双击
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:doubleTap];
        
        // 区别出单机双击
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
}

- (void)reFreshUI
{
    _scrollView.zoomScale = 1.0f; // 放大倍数还原
    _scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap
{
    if([self.superview.superview isKindOfClass:[JZPhotoAlbumView class]])
    {
        [self.superview.superview performSelector:@selector(photoAlbumViewCellDidSelected:) withObject:self];
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    CGFloat newScale = _scrollView.zoomScale;
    if(newScale <= _maximumZoomScale)
    {
        newScale += 1.5;
        if(newScale > _maximumZoomScale)
        {
            newScale = 1.0f;
        }
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [_scrollView zoomToRect:zoomRect animated:YES];
    _tapClicks = !_tapClicks;
}

#pragma mark - CommonMethods
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = _scrollView.frame.size.height / scale;
    zoomRect.size.width  = _scrollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - zoomRect.size.width;
    zoomRect.origin.y = center.y - zoomRect.size.height;
    return zoomRect;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat horizontal = (self.imageView.frame.size.width - _oldWidth)/2;
    horizontal = horizontal>0?horizontal:0;
    CGFloat vertical = (self.imageView.frame.size.height-_oldHeight)/2;
    vertical = vertical>0?vertical:0;
    scrollView.contentInset = UIEdgeInsetsMake(vertical, horizontal, -vertical, -horizontal);
    self.imageView.center = _oldPoint; // 保持图片居中
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!_isNeedTapZoom && [self.superview.superview isKindOfClass:[JZPhotoAlbumView class]])
    {
        [self.superview.superview performSelector:@selector(photoAlbumViewCellDidSelected:) withObject:self];
    }
}

@end
