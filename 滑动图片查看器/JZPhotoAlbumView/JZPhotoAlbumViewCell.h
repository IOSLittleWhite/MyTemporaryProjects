//
//  JZPhotoAlbumViewCell.h
//  JZBPM
//
//  Created by JZ_Stone on 14-10-14.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZImageViewAutoFitImageSize.h"

@interface JZPhotoAlbumViewCell : UIView<UIScrollViewDelegate>

@property (nonatomic, copy) NSString * reuseIdentifier;
@property (nonatomic, strong) JZImageViewAutoFitImageSize *imageView;
@property (nonatomic, assign) BOOL isNeedBeZoom; // 是否可以手动拉伸放大
@property (nonatomic, assign) BOOL isAutoFitImageSize;
@property (nonatomic, assign) BOOL isNeedTapZoom; // 是否需要双击放大
@property (nonatomic, assign) CGFloat maximumZoomScale;
@property (nonatomic, assign) CGFloat minimumZoomScale;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void)reFreshUI;

@end
