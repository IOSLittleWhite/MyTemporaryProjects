//
//  JZScrollView.m
//  JZBPM
//
//  Created by JZ_Stone on 15/1/14.
//  Copyright (c) 2015年 广州九章信息科技有限公司. All rights reserved.
//

#import "JZScrollView.h"

@implementation JZScrollView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.superview touchesEnded:touches withEvent:event]; // 向父视图穿透点击
}

@end
