//
//  JZImageViewAutoFitImageSize.h
//  JZBPM
//
//  Created by JZ_Stone on 14-10-14.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZImageView.h"
#import "UIImageView+AttachmentCache.h"

@interface JZImageViewAutoFitImageSize : UIImageView

/**
 * 是否根据图片尺寸自动调整imageView的frame
 */
@property (nonatomic, assign) BOOL isAutoFitImageSize;

@end
