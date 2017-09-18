//
//  YFNewFeatureViewController.m
//  YFPlayerPushStreaming-Demo
//
//  Created by apple on 3/31/17.
//  Copyright © 2017 YunFan. All rights reserved.
//

#import "YFNewFeatureViewController.h"
#import "Masonry.h"
#import "YFLiveSetViewController.h"
#import "YFRecordSetViewController.h"
#import "YFRecordViewController.h"
#define NewfeatureImageCount 4
@interface YFNewFeatureViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIButton *liveBtn;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (strong,nonatomic)NSTimer *timer;

@end

@implementation YFNewFeatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.bgImageView];
    [self setupScrollView];
    [self setupPageControl];
    [self setupSubView];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)setupSubView{
    __weak typeof(self)weakSelf = self;
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(30);
        make.left.equalTo(weakSelf.view).offset(10);
        make.right.equalTo(weakSelf.view).offset(-10);
        make.bottom.equalTo(weakSelf.view).offset(-150);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView.mas_bottom).offset(10);
        make.centerX.equalTo(weakSelf.view);
    }];
    
    [self.liveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(80);
        make.bottom.equalTo(weakSelf.view).offset(-35);
        make.size.mas_equalTo(CGSizeMake(75, 75));
    }];
    
    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-80);
        make.bottom.equalTo(weakSelf.view).offset(-35);
        make.size.mas_equalTo(CGSizeMake(75, 75));
    }];
}

- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    self.scrollView = scrollView;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat imageW = screenSize.width - 20;
    CGFloat imageH = screenSize.height - 180;
    for (int i = 0; i < NewfeatureImageCount; ++i) {
        // 创建图片
        UIImageView *iconView = [[UIImageView alloc] init];
        NSString *imageName = [NSString stringWithFormat:@"guide%d",i + 1];
        iconView.image = [UIImage imageNamed:imageName];
        CGFloat iconX = i * imageW;
        CGFloat iconY = 0;
        iconView.frame = CGRectMake(iconX, iconY, imageW, imageH);
        [scrollView addSubview:iconView];
    }
    scrollView.contentSize = CGSizeMake(NewfeatureImageCount* imageW, 0);
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    [self.view addSubview:scrollView];
}

/**
 *  创建分页指示器
 */
- (void)setupPageControl {
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = NewfeatureImageCount;
    pageControl.currentPageIndicatorTintColor = [UIColor yellowColor];
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
}

#pragma mark - UIScrollViewDelegate 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 获得x方向的偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    // 计算✌️号
    NSInteger page = offsetX / scrollView.frame.size.width + 0.5;
    self.pageControl.currentPage = page;
}

//用户拖拉时，计时器停止
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.timer invalidate];
    
}
//当用户拖拽结束时，计时器开始
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    CGPoint offset = self.scrollView.contentOffset;
    offset.x += self.scrollView.bounds.size.width;
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)nextPage{
    CGPoint offset = self.scrollView.contentOffset;
    offset.x += self.scrollView.bounds.size.width;
    if (offset.x >= (NewfeatureImageCount-1)*self.scrollView.bounds.size.width) {
        [self.timer invalidate];
    }
    if (offset.x < (NewfeatureImageCount)*self.scrollView.bounds.size.width) {
        [self.scrollView setContentOffset:offset animated:YES];
    }
}

- (void)liveSet:(UIButton *)sender{
    YFLiveSetViewController *vc = [[YFLiveSetViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)recordSet:(UIButton *)sender{
    YFRecordSetViewController *vc = [[YFRecordSetViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
    NSTimer *timer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)dealloc{
    [self.timer invalidate];
}

#pragma mark 

- (UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
    }
    return _bgImageView;
}

- (UIButton *)liveBtn{
    if (!_liveBtn) {
        _liveBtn = [[UIButton alloc] init];
        [_liveBtn setBackgroundImage:[UIImage imageNamed:@"zhibo1"] forState:UIControlStateNormal];
        [_liveBtn setBackgroundImage:[UIImage imageNamed:@"zhibo2"] forState:UIControlStateHighlighted];
        [_liveBtn addTarget:self action:@selector(liveSet:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_liveBtn];
    }
    return _liveBtn;
}

- (UIButton *)recordBtn{
    if (!_recordBtn) {
        _recordBtn = [[UIButton alloc] init];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"lubo1"] forState:UIControlStateNormal];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"lubo2"] forState:UIControlStateHighlighted];
        [_recordBtn addTarget:self action:@selector(recordSet:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_recordBtn];
    }
    return _recordBtn;
}

@end
