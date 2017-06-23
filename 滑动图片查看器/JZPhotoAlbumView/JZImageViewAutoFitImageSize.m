//
//  JZImageViewAutoFitImageSize.m
//  JZBPM
//
//  Created by JZ_Stone on 14-10-14.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import "JZImageViewAutoFitImageSize.h"
#import "JZColorMaker.h"

@implementation JZImageViewAutoFitImageSize
{
    CGFloat _widthHeightRate; // self宽高比
    CGRect _oldFrame;
    CGPoint _oldCenter;
}

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        _isAutoFitImageSize = YES;
        
        _widthHeightRate = frame.size.width/frame.size.height;
        self.contentMode = UIViewContentModeScaleAspectFit;
        _oldFrame = frame;
        _oldCenter = self.center;
    }
    return self;
}

// 根据图片size调整ImageView的frame
- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    if(_isAutoFitImageSize)
    {
        CGSize imageSize = image.size;
        if(imageSize.width<=_oldFrame.size.width && imageSize.height<_oldFrame.size.height)
        {
            self.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
            self.center = _oldCenter;
        }
        else
        {
            CGFloat imageRate = imageSize.width/imageSize.height;
            if(_widthHeightRate < 1) // 如果是竖屏
            {
                if(imageRate <= _widthHeightRate) // 添加的是高瘦型图片
                {
                    // self.frame的高度不变，调整宽度来适应图片
                    CGFloat width = _oldFrame.size.height * imageRate;
                    CGFloat newX = (_oldFrame.size.width - width)/2;
                    self.frame = CGRectMake(newX, _oldFrame.origin.y, width, _oldFrame.size.height);
                }
                else
                {
                    CGFloat height = _oldFrame.size.width / imageRate;
                    CGFloat newY = (_oldFrame.size.height - height)/2;
                    self.frame = CGRectMake(_oldFrame.origin.x, newY, _oldFrame.size.width, height);
                }
            }
            else
            {
                if(imageRate <= _widthHeightRate) // 添加的是高瘦型图片
                {
                    CGFloat width = _oldFrame.size.width / imageRate;
                    CGFloat newX = (_oldFrame.size.width - width)/2;
                    self.frame = CGRectMake(newX, _oldFrame.origin.y, width, _oldFrame.size.height);
                }
                else
                {
                    CGFloat height = _oldFrame.size.height * imageRate;
                    CGFloat newY = (_oldFrame.size.height - height)/2;
                    self.frame = CGRectMake(_oldFrame.origin.x, newY, _oldFrame.size.width, height);
                }
            }
        }
    }
    else
    {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
}

@end







