//
//  YFLiveViewController.h
//  YFPlayerPushStreaming-Demo
//
//  Created by apple on 3/31/17.
//  Copyright © 2017 YunFan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YFMediaPlayerPushStreaming/YFMediaPlayerPushStreaming.h>
@interface YFLiveViewController : UIViewController

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, assign) BOOL isVertical;
@property (nonatomic, assign) CGFloat kbps;
@property (nonatomic, assign) CGFloat fps;
@property (nonatomic, assign) YfTransportStyle transportStyle;

@end
