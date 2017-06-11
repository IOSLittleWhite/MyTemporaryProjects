//
//  ViewController.m
//  HeadScrollView
//
//  Created by JZ_Stone on 15/11/20.
//  Copyright © 2015年 JZ_Stone. All rights reserved.
//

#import "ViewController.h"
#import "HMHeadScrollView.h"
#import "NextViewController.h"
#import "Masonry.h"

@interface ViewController ()<HMHeadScrollViewDataSource, HMHeadScrollViewDelegate>
{
    NSMutableArray *_labels;
    HMHeadScrollView *_tabView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    _labels = [NSMutableArray array];
    
    _tabView = [[HMHeadScrollView alloc] init];
    _tabView.dataSource = self;
    _tabView.delegate = self;
    [self.view addSubview:_tabView];
    
    [_tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.mas_equalTo(64);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 200, 200, 40);
    [button setTitle:@"下一页" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:@[@"下划线", @"方框", @"圆圈"]];
    seg.frame = CGRectMake(10, 350, 300, 40);
    [seg setSelectedSegmentIndex:0];
    [seg addTarget:self action:@selector(styleChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:seg];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goNext
{
    NextViewController *nextVc = [[NextViewController alloc] init];
    [self.navigationController pushViewController:nextVc animated:YES];
}

- (void)styleChange:(UISegmentedControl *)seg
{
    if(seg.selectedSegmentIndex == 0)
    {
        _tabView.selectedStyle = HMHeadScrollViewSeletedStyleUnderLine;
    }
    else if(seg.selectedSegmentIndex == 1)
    {
        _tabView.selectedStyle = HMHeadScrollViewSeletedStyleBackSquare;
    }
    else
    {
        _tabView.selectedStyle = HMHeadScrollViewSeletedStyleBackCircle;
    }
}


#pragma mark - HMHeadScrollViewDataSource
- (CGFloat)headHeightForTabHeadView:(HMHeadScrollView *)headScrollView
{
    return 50;
}

- (CGFloat)headScrollView:(HMHeadScrollView *)headScrollView widthForHeadCellAtIndex:(NSInteger)index
{
    if(index%2)
    {
        return 100;
    }
    return 50;
}

- (NSInteger)numberOfTabsForHeadScrollView:(HMHeadScrollView *)headScrollView
{
    return 10;
}

// 设置头部的tab按钮
// 头部各个tab的视图
- (UIView *)headScrollView:(HMHeadScrollView *)headScrollView headCellViewForHeadAtIndex:(NSInteger)index
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"(%ld)", index]];
    return imageView;
}

- (UIView *)headScrollView:(HMHeadScrollView *)headScrollView contentCellViewForContentAtIndex:(NSInteger)index
{
    UIView *view = [[UIView alloc] init];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 200, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15.0f];
    label.text = [NSString stringWithFormat:@"test %ld", index];
    [view addSubview:label];
    [_labels addObject:label];
    return view;
}


#pragma mark - HMHeadScrollViewDelegate
- (void)headScrollView:(HMHeadScrollView *)headScrollView didSeletTabAtIndex:(NSInteger)index
{
    UILabel *label = _labels[index];
    self.title = label.text;
}

@end
