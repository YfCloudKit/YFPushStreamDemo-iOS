//
//  YFRecordSetViewController.m
//  YFPlayerPushStreaming-Demo
//
//  Created by apple on 4/11/17.
//  Copyright © 2017 YunFan. All rights reserved.
//

#import "YFRecordSetViewController.h"
#import "Masonry.h"
#import "YFRecordViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface YFRecordSetViewController ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *setBG;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UILabel *savetitle;
@property (nonatomic, strong) UILabel *savePath;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *exitBtn;

@end

@implementation YFRecordSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSubView];
    [self authCameraLicence];
}

- (void)authCameraLicence{
    //    __weak typeof(self) weakSelf = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            //许可对话没有出现，发起授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    //许可完成
                    NSLog(@"第一次开启授权。。");
                }
                
            }];
            break;
        case AVAuthorizationStatusAuthorized:{
            //已经开启过授权了
            NSLog(@"开启过授权了");
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (audioStatus) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                NSLog(@"第一次开启麦克风");
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            NSLog(@"开启过麦克风");
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

- (void)setupSubView{
    
    __weak typeof(self)weakSelf = self;
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    [self.setBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(40);
        make.left.equalTo(weakSelf.view).offset(15);
        make.right.equalTo(weakSelf.view).offset(-15);
        make.bottom.equalTo(weakSelf.view).offset(-150);
    }];
    
    [self.selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.top.equalTo(weakSelf.setBG).offset(30);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.setBG).offset(30);
        make.right.equalTo(weakSelf.setBG).offset(-15);
        make.size.mas_equalTo(CGSizeMake(140, 30));
    }];
    
    [self.line  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.selectLabel.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.right.equalTo(weakSelf.setBG).offset(-15);
        make.height.mas_equalTo(2);
    }];
    
    [self.savetitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.line.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    [self.savePath mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.savetitle.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.right.equalTo(weakSelf.setBG).offset(-15);
        make.height.mas_equalTo(100);
    }];
    
    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.setBG.mas_bottom).offset(-100);
        make.centerX.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(160, 40));
    }];
    
    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view).offset(-50);
        make.centerX.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(47, 47));
    }];
    
}

- (void)startRecord:(UIButton *)sender{
    
    YFRecordViewController *recordVc = [[YFRecordViewController alloc] init];
    recordVc.isVertical = !self.selectBtn.selected;
    [self.navigationController pushViewController:recordVc animated:YES];
}

- (void)selectSetType:(UIButton *)sender{
    if (!sender.selected) {
        sender.selected = YES;
        [sender setTitle:@"横屏直播 >" forState:UIControlStateNormal];
    }else{
        sender.selected = NO;
        [sender setTitle:@"竖屏直播 >" forState:UIControlStateNormal];
    }
}

- (void)exitRecordSetView:(UIButton *)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
        [self.view addSubview:_bgImageView];
    }
    return _bgImageView;
}

- (UIImageView *)setBG{
    if (!_setBG) {
        _setBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"luzhiset"]];
        [self.view addSubview:_setBG];
    }
    return _setBG;
}

- (UILabel *)selectLabel{
    if (!_selectLabel) {
        _selectLabel = [[UILabel alloc] init];
        _selectLabel.text = @"横竖屏";
        _selectLabel.textColor = [UIColor whiteColor];
        _selectLabel.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_selectLabel];
    }
    return _selectLabel;
}

- (UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [[UIButton alloc] init];
        _selectBtn.selected = NO;
        [_selectBtn setTitle:@"竖屏直播 >" forState:UIControlStateNormal];
        [_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectBtn addTarget:self action:@selector(selectSetType:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_selectBtn];
    }
    return _selectBtn;
}

- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRed:87/255.0 green:128/255.0 blue:127/255.0 alpha:1];
        [self.view addSubview:_line];
    }
    return _line;
}

- (UILabel *)savetitle{
    if (!_savetitle) {
        _savetitle = [[UILabel alloc] init];
        _savetitle.text = @"保存路径";
        _savetitle.textColor = [UIColor whiteColor];
        _savetitle.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_savetitle];
    }
    return _savetitle;
}

- (UILabel *)savePath{
    if (!_savePath) {
        _savePath = [[UILabel alloc] init];
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        filePath = [filePath stringByAppendingPathComponent:@"test.flv"];
        _savePath.text = filePath;
        _savePath.numberOfLines = 0;
        _savePath.textColor = [UIColor whiteColor];
        _savePath.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_savePath];
    }
    return _savePath;
}

- (UIButton *)recordBtn{
    if (!_recordBtn) {
        _recordBtn = [[UIButton alloc] init];
        [_recordBtn setTitle:@"开始录制" forState:UIControlStateNormal];
        [_recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"startLive1"] forState:UIControlStateNormal];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"startLive2"] forState:UIControlStateHighlighted];
        [_recordBtn addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_recordBtn];
    }
    return _recordBtn;
}


- (UIButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [[UIButton alloc] init];
        [_exitBtn setBackgroundImage:[UIImage imageNamed:@"close1"] forState:UIControlStateNormal];
        [_exitBtn setBackgroundImage:[UIImage imageNamed:@"close2"] forState:UIControlStateHighlighted];
        [_exitBtn addTarget:self action:@selector(exitRecordSetView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_exitBtn];
    }
    return _exitBtn;
}


@end
