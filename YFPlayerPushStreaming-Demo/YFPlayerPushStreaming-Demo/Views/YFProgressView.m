//
//  YFProgressView.m
//  YFPlayerPushStreaming-Demo
//
//  Created by apple on 5/16/17.
//  Copyright © 2017 YunFan. All rights reserved.
//

#import "YFProgressView.h"
@implementation YFProgressView

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, 0, 5);
    CGContextAddLineToPoint(ctx, self.progress*([UIScreen mainScreen].bounds.size.width/30), 5);
    
    [[UIColor colorWithRed:255/255.0 green:25/255.0 blue:119/255.0 alpha:1] set];
    CGContextSetLineWidth(ctx, 10);
    //3.通知系统绘制
    CGContextStrokePath(ctx);
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

@end
