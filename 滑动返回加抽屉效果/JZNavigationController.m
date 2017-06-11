//
//  JZNavigationController.m
//  JZBPM_MI
//
//  Created by JZ_Stone on 14-7-3.
//  Copyright (c) 2014年 广州九章信息科技有限公司. All rights reserved.
//

#import "JZNavigationController.h"
#import "JZFilesDownloadManage.h"

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]


#pragma mark - JZNavigationBar 子类化UINavigationBar
@interface JZNavigationBar : UINavigationBar
@end

@implementation JZNavigationBar
//禁用导航栏的pop动画
- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated
{
    return [super popNavigationItemAnimated:NO];
}
@end



@interface JZNavigationController ()
{
    UIImageView *_backImageView;
    UIView *_alphaView;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *backImages;

@end


@implementation JZNavigationController
#pragma mark - 生命周期
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.backImages = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isNeedCancelAllRequest = YES;
    
    //抽屉式导航
    JZNavigationBar *navigationBar = [[JZNavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    [self setValue:navigationBar forKey:@"navigationBar"];
    
    //改变导航栏字体的颜色
    UIColor * color = [UIColor whiteColor];
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:color,UITextAttributeTextColor,font,UITextAttributeFont, nil];
    navigationBar.titleTextAttributes = dict;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - override UINavigationController方法覆写
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIImage *capture = [self capture]; // 获取当前屏幕快照
    if (capture != nil)
    {
        [self.backImages addObject:capture]; // 保存push前的屏幕快照
    }
    [super pushViewController:viewController animated:NO];
    
    if (self.backgroundView == nil)
    {
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundView = [[UIView alloc] initWithFrame:frame];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        
        _backImageView = [[UIImageView alloc] initWithFrame:frame];
        [self.backgroundView addSubview:_backImageView];
        _alphaView = [[UIView alloc] initWithFrame:frame];
        _alphaView.backgroundColor = [UIColor blackColor];
        [self.backgroundView addSubview:_alphaView];
    }
    if (self.backgroundView.superview == nil)
    {
        [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
    }
    if (self.viewControllers.count == 1)
    {
        return;
    }
    
    _backImageView.image = [self.backImages lastObject];
    _alphaView.alpha = 0;
    if(animated)
    {
        [self moveViewWithX:[UIScreen mainScreen].bounds.size.width];
        [UIView animateWithDuration:0.4 animations:^{
            [self moveViewWithX:0];
        }];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if(_isNeedCancelAllRequest && ![[JZFilesDownloadManage sharedFilesDownloadManage] isExitDownloadingTask])
    {
        [[ASIHTTPRequest sharedQueue] cancelAllOperations];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JZNavigationPopBackNotification object:nil];
    _navPopDelegate = nil;
    
    if (self.view.frame.origin.x == 0)
    {
        _backImageView.transform = CGAffineTransformMakeScale(0.95, 0.95); // 下层快照图片缩小
    }
    if(animated)
    {
        [UIView animateWithDuration:0.4 animations:^{
            [self moveViewWithX:[UIScreen mainScreen].bounds.size.width]; // 讲view向右移出屏幕
        } completion:^(BOOL finished) {
            CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            frame.origin.x = 0;
            self.view.frame = frame;
            [super popViewControllerAnimated:NO];
            
            [self.backImages removeLastObject];
            _backImageView.image = [self.backImages lastObject];
        }];
    }
    else
    {
        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        frame.origin.x = 0;
        self.view.frame = frame;
        
        [super popViewControllerAnimated:NO];
        
        [self.backImages removeLastObject];
        _backImageView.image = [self.backImages lastObject];
    }
    _isNeedCancelAllRequest = YES;
    return nil;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    [_backImages removeAllObjects];
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - Utility Methods -
//获取当前屏幕视图的快照图片
- (UIImage *)capture
{
    UIView *view = self.view.superview;
    if (view == nil)
    {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//移动导航控制器的根视图self.view
- (void)moveViewWithX:(float)x
{
    x = x>[UIScreen mainScreen].bounds.size.width?[UIScreen mainScreen].bounds.size.width:x;
    x = x<0?0:x;
    
    self.view.frame = CGRectMake(x, 0, self.view.frame.size.width, self.view.frame.size.height);;
    float scale = (x/([UIScreen mainScreen].bounds.size.width*20))+0.95;
    float alpha = 0.4 - (x/800);
    _backImageView.transform = CGAffineTransformMakeScale(scale, scale);
    _alphaView.alpha = alpha;
}

#pragma mark - JZNavigationCanDragBackDelegate
- (void)navDragMoveWithX:(CGFloat)x
{
    if(self.viewControllers.count > 1)
    {
       [self moveViewWithX:x];
    }
}

- (void)navDragStopWithX:(CGFloat)x
{
    if (self.viewControllers.count > 1)
    {
        if (x > [UIScreen mainScreen].bounds.size.width/10)
        {
            if(_navPopDelegate != nil && [_navPopDelegate respondsToSelector:@selector(navigationWillSlideToPopBack)])
            {
                [_navPopDelegate navigationWillSlideToPopBack];
            }
            else
            {
                [self navPopBack];
            }
        }
        else
        {
            [self navStayAtCurrentPage];
        }
    }
}

- (void)navDragCancal
{
    [self navStayAtCurrentPage];
}


#pragma mark - 暴露给外界使用
- (void)navPopBack
{
    [self popViewControllerAnimated:YES];
}

- (void)navStayAtCurrentPage
{
    [UIView animateWithDuration:0.4 animations:^{
        [self moveViewWithX:0];
    }];
}

- (void)dealloc
{
    [_backImages removeAllObjects];
    _backImages = nil;
    _backgroundView = nil;
    _backImageView = nil;
    _navPopDelegate = nil;
}


@end










