//
//  YFLiveSetViewController.m
//  YFPlayerPushStreaming-Demo
//
//  Created by apple on 3/31/17.
//  Copyright © 2017 YunFan. All rights reserved.
//

#import "YFLiveSetViewController.h"
#import "Masonry.h"
#import "YFDetailView.h"
#import "YFLiveViewController.h"
#import <YFMediaPlayerPushStreaming/YFMediaPlayerPushStreaming.h>
#import "YfLisenceManger.h"
@interface YFLiveSetViewController ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *setBG;
@property (nonatomic, strong) UILabel *selectLabel;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UILabel *urlLabel;
@property (nonatomic, strong) UITextField *inText;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIView *line2;
@property (nonatomic, strong) UILabel *weakNet;
@property (nonatomic, strong) UIButton *questionBtn;
@property (nonatomic, strong) YFDetailView *detailView;
@property (nonatomic, strong) UIButton *udpBtn;
@property (nonatomic, strong) UIView *line3;
@property (nonatomic, strong) UIButton *setBtn;
@property (nonatomic, strong) UITextField *kbpsText;
@property (nonatomic, strong) UITextField *fpsText;
@property (nonatomic, strong) UILabel *kbpsLabel;
@property (nonatomic, strong) UILabel *fpsLabel;
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *exitBtn;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) YfTransportStyle transportStyle;

@end

@implementation YFLiveSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.transportStyle = YfTransportNone;
    self.index = 1;
    [self setSubView];
    
    
    [YfLisenceManger LisenceWithAK:"5cac66cf999fba09a9aabe674d21a82098d597d4" Token:"fc00e8546afd27dbce70222c2a8f963f337fdaea" YfAuthResult:^(int flag, NSString *description) {
        NSLog(@"%d=licence = %@",flag,description);
    }];
    
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


- (void)setSubView{
    //布局
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
    
    [self.urlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.line.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.size.mas_equalTo(CGSizeMake(160, 30));
    }];
    
    [self.inText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.top.equalTo(weakSelf.urlLabel.mas_bottom).offset(10);
        make.right.equalTo(weakSelf.setBG).offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.inText.mas_bottom);
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.right.equalTo(weakSelf.setBG).offset(-15);
        make.height.mas_equalTo(50);
    }];
    
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.right.equalTo(weakSelf.setBG).offset(-15);
        make.top.equalTo(weakSelf.tipLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(2);
    }];
    
    [self.weakNet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.line2.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.size.mas_equalTo(CGSizeMake(80, 20));
    }];
    
    [self.questionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.weakNet.mas_right).offset(5);
        make.top.equalTo(weakSelf.line2).offset(10);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.setBG).offset(5);
        make.top.equalTo(weakSelf.questionBtn.mas_bottom);
        make.right.equalTo(weakSelf.setBG).offset(-5);
        make.height.mas_equalTo(0);
    }];
    
    [self.udpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.line2).offset(10);
        make.right.equalTo(weakSelf.view).offset(-15);
        make.size.mas_equalTo(CGSizeMake(84, 20));
    }];
    
    [self.line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.weakNet.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.right.equalTo(weakSelf.setBG).offset(-15);
        make.height.mas_equalTo(2);
    }];
    
    [self.setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.line3.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.setBG).offset(15);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self.kbpsText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.setBtn.mas_right).offset(10);
        make.top.equalTo(weakSelf.setBtn).offset(5);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    [self.kbpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.kbpsText.mas_right).offset(5);
        make.top.equalTo(weakSelf.setBtn).offset(5);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    [self.fpsText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.kbpsLabel.mas_right).offset(20);
        make.top.equalTo(weakSelf.setBtn).offset(5);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    [self.fpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.fpsText.mas_right).offset(5);
        make.top.equalTo(weakSelf.setBtn).offset(5);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.setBtn.mas_bottom).offset(50);
        make.centerX.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(160, 40));
    }];
    
    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view).offset(-50);
        make.centerX.equalTo(weakSelf.view);
        make.size.mas_equalTo(CGSizeMake(47, 47));
    }];
    
}

- (void)selectType:(UIButton *)sender{
    if (!sender.selected) {
        sender.selected = YES;
        [sender setTitle:@"横屏直播 >" forState:UIControlStateNormal];
    }else{
        sender.selected = NO;
        [sender setTitle:@"竖屏直播 >" forState:UIControlStateNormal];
    }
}

- (void)displayDetail:(UIButton *)sender{
    int alpha = 0;
    if (!sender.selected) {
        sender.selected = YES;
        alpha = 0;
        [self.detailView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(200);
        }];
    }else{
        sender.selected = NO;
        alpha = 1;
        [self.detailView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        self.startBtn.alpha = alpha;
    }];
    
}

- (void)selectUdpOrFec:(UIButton *)sender{
    //dispatch_async(dispatch_get_main_queue(), ^{
        switch (self.index) {
            case 0:
                self.index = 1;
                self.transportStyle = YfTransportNone;
                [sender setTitle:@"TCP >" forState:UIControlStateNormal];
                break;
            case 1:
                self.index = 0;
                self.transportStyle = YfTransportUDP;
                [sender setTitle:@"UDP >" forState:UIControlStateNormal];
                break;
            case 2:
                self.index = 0;
                self.transportStyle = YfTransportFEC;
                [sender setTitle:@"FEC >" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
 
   // });
}

- (void)setFpsAndBps:(UIButton *)sender{
    
    if (sender.selected) {
        sender.selected = NO;
        [self.kbpsText mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        [self.kbpsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        [self.fpsText mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        [self.fpsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        
    }else{
        sender.selected = YES;
        [self.kbpsText mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(60);
        }];
        [self.kbpsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
           make.width.mas_equalTo(60);
        }];
        [self.fpsText mas_updateConstraints:^(MASConstraintMaker *make) {
           make.width.mas_equalTo(60);
        }];
        [self.fpsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
           make.width.mas_equalTo(60);
        }];
    }
    
    [self.view updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
       [self.view layoutIfNeeded];
    }];
}

- (void)startLive:(UIButton *)sender{
    //开始直播
    YFLiveViewController *liveVc = [[YFLiveViewController alloc] init];
    liveVc.urlString = self.inText.text;
    liveVc.isVertical = !self.selectBtn.selected;
    liveVc.transportStyle = self.transportStyle;
    liveVc.kbps = [self.kbpsText.text intValue];
    liveVc.fps = [self.fpsText.text intValue];
    [self.navigationController pushViewController:liveVc animated:YES];
}

- (void)exitSetView:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark 懒加载

- (UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG"]];
        [self.view addSubview:_bgImageView];
    }
    return _bgImageView;
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
        [_selectBtn addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_selectBtn];
    }
    return _selectBtn;
}

- (UIImageView *)setBG{
    if (!_setBG) {
        _setBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"set_bg"]];
        [self.view addSubview:_setBG];
    }
    return _setBG;
}

- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor colorWithRed:87/255.0 green:128/255.0 blue:127/255.0 alpha:1];
        [self.view addSubview:_line];
    }
    return _line;
}

- (UILabel *)urlLabel{
    if (!_urlLabel) {
        _urlLabel = [[UILabel alloc] init];
        _urlLabel.textAlignment = NSTextAlignmentLeft;
        _urlLabel.textColor = [UIColor whiteColor];
        _urlLabel.text = @"直播源流地址";
        [self.view addSubview:_urlLabel];
    }
    return _urlLabel;
}

- (UITextField *)inText{
    if (!_inText) {
        _inText = [[UITextField alloc] init];
        _inText.text = @"rtmp://push-zk.yftest.yflive.net/live/test33";
        _inText.textColor = [UIColor whiteColor];
        _inText.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_inText];
    }
    return _inText;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.numberOfLines = 0;
        _tipLabel.text = @"(我们提供一条基于rtmp协议的直播源流地址,您也可以使用其他有效的直播源流地址.)";
        _tipLabel.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1];
        [self.view addSubview:_tipLabel];
    }
    return _tipLabel;
}

- (UIView *)line2{
    if (!_line2) {
        _line2 = [[UIView alloc] init];
        _line2.backgroundColor = [UIColor colorWithRed:87/255.0 green:128/255.0 blue:127/255.0 alpha:1];
        [self.view addSubview:_line2];
    }
    return _line2;
}

- (UILabel *)weakNet{
    if (!_weakNet) {
        _weakNet = [[UILabel alloc] init];
        _weakNet.text = @"弱网直播";
        _weakNet.textColor = [UIColor whiteColor];
        [self.view addSubview:_weakNet];
    }
    return _weakNet;
}

- (UIButton *)questionBtn{
    if (!_questionBtn) {
        _questionBtn = [[UIButton alloc] init];
        _questionBtn.selected = NO;
        [_questionBtn setBackgroundImage:[UIImage imageNamed:@"zhibotip2"] forState:UIControlStateNormal];
        [_questionBtn setBackgroundImage:[UIImage imageNamed:@"zhibotip1"] forState:UIControlStateSelected];
        [_questionBtn addTarget:self action:@selector(displayDetail:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_questionBtn];
    }
    return _questionBtn;
}

- (YFDetailView *)detailView{
    if (!_detailView) {
        _detailView = [[YFDetailView alloc] init];
        _detailView.clipsToBounds = YES;
        [self.view addSubview:_detailView];
    }
    return _detailView;
}

- (UIButton *)udpBtn{
    if (!_udpBtn) {
        _udpBtn = [[UIButton alloc] init];
        _udpBtn.selected = NO;
        [_udpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_udpBtn setTitle:@"TCP >" forState:UIControlStateNormal];
        _udpBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_udpBtn addTarget:self action:@selector(selectUdpOrFec:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_udpBtn];
    }
    return _udpBtn;
}

- (UIView *)line3{
    if (!_line3) {
        _line3 = [[UIView alloc] init];
        _line3.backgroundColor = [UIColor colorWithRed:87/255.0 green:128/255.0 blue:127/255.0 alpha:1];
        [self.view addSubview:_line3];
    }
    return _line3;
}

- (UIButton *)setBtn{
    if (!_setBtn) {
        _setBtn = [[UIButton alloc] init];
        _setBtn.selected = NO;
        [_setBtn setBackgroundImage:[UIImage imageNamed:@"set1"] forState:UIControlStateNormal];
        [_setBtn setBackgroundImage:[UIImage imageNamed:@"set2"] forState:UIControlStateHighlighted];
        [_setBtn addTarget:self action:@selector(setFpsAndBps:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_setBtn];
    }
    return _setBtn;
}

- (UITextField *)kbpsText{
    if (!_kbpsText) {
        _kbpsText = [[UITextField alloc] init];
        _kbpsText.text = @"800";
        _kbpsText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"码率" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        _kbpsText.textColor = [UIColor whiteColor];
        _kbpsText.keyboardType = UIKeyboardTypePhonePad;
        [self.view addSubview:_kbpsText];
    }
    return _kbpsText;
}

- (UILabel *)kbpsLabel{
    if (!_kbpsLabel) {
        _kbpsLabel = [[UILabel alloc] init];
        _kbpsLabel.text = @"kbps";
        _kbpsLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_kbpsLabel];
    }
    return _kbpsLabel;
}

- (UITextField *)fpsText{
    if (!_fpsText) {
        _fpsText = [[UITextField alloc] init];
        _fpsText.text = @"24";
        _fpsText.keyboardType = UIKeyboardTypePhonePad;
        _fpsText.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"帧率" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        _fpsText.textColor = [UIColor whiteColor];
        [self.view addSubview:_fpsText];
    }
    return _fpsText;
}

- (UILabel *)fpsLabel{
    if (!_fpsLabel) {
        _fpsLabel = [[UILabel alloc] init];
        _fpsLabel.text = @"fps";
        _fpsLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_fpsLabel];
    }
    return _fpsLabel;
}

- (UIButton *)startBtn{
    if (!_startBtn) {
        _startBtn = [[UIButton alloc] init];
        [_startBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startBtn setBackgroundImage:[UIImage imageNamed:@"startLive1"] forState:UIControlStateNormal];
        [_startBtn setBackgroundImage:[UIImage imageNamed:@"startLive2"] forState:UIControlStateHighlighted];
        [_startBtn addTarget:self action:@selector(startLive:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_startBtn];
    }
    return _startBtn;
}

- (UIButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [[UIButton alloc] init];
        [_exitBtn setBackgroundImage:[UIImage imageNamed:@"close1"] forState:UIControlStateNormal];
        [_exitBtn setBackgroundImage:[UIImage imageNamed:@"close2"] forState:UIControlStateHighlighted];
        [_exitBtn addTarget:self action:@selector(exitSetView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_exitBtn];
    }
    return _exitBtn;
}

@end
