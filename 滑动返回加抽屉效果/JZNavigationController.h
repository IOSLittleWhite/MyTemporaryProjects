//
//  JZNavigationController.h
//  JZBPM_MI
//
//  Created by JZ_Stone on 14-7-3.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JZNavigationPopBackDelegate <NSObject>

/**
 * 即将滑动返回时调用
 */
- (void)navigationWillSlideToPopBack;

@end

#define JZNavigationPopBackNotification @"JZNavigationPopBack"

@interface JZNavigationController : UINavigationController

@property (nonatomic, weak) id<JZNavigationPopBackDelegate> navPopDelegate;
@property (nonatomic, assign) BOOL isNeedCancelAllRequest;

- (void)navPopBack;
- (void)navStayAtCurrentPage;

@end
