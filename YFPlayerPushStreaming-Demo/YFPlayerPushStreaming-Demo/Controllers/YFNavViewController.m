//
//  YFNavViewController.m
//  YFPlayerPushStreaming-Demo
//
//  Created by apple on 3/31/17.
//  Copyright © 2017 YunFan. All rights reserved.
//

#import "YFNavViewController.h"

@interface YFNavViewController ()

@end

@implementation YFNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.hidesBottomBarWhenPushed = YES;
    [self setNavigationBarHidden:YES];
    [super pushViewController:viewController animated:animated];
}

@end
