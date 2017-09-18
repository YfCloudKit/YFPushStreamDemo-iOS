//
//  YFRecordViewController.m
//  YFPlayerPushStreaming-Demo
//
//  Created by apple on 3/31/17.
//  Copyright © 2017 YunFan. All rights reserved.
//

#import "YFRecordViewController.h"
#import <YFMediaPlayerPushStreaming/YFMediaPlayerPushStreaming.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "Masonry.h"
#import "YFRecordSettingView.h"
#import "YFBeautyView.h"
#import "YFARView.h"
#import "YFWaterMarkView.h"
#import <AVFoundation/AVFoundation.h>

@interface YFRecordViewController ()<YfSessionDelegate>
//UI
@property (nonatomic, strong) UIButton *exitBtn;
@property (nonatomic, strong) UIImageView *bgImageview;
@property (nonatomic, strong) UILabel *tipTitle;
@property (nonatomic, strong) UIButton *switchCamera;
@property (nonatomic, strong) UIButton *setBtn;
@property (nonatomic, strong) YFRecordSettingView *settingView;
@property (nonatomic, strong) YFBeautyView *beautyView;
@property (nonatomic, strong) YFARView *arView;
@property (nonatomic, strong) YFWaterMarkView *waterMark;
@property (nonatomic, strong) NSArray *bundleArr;
@property (nonatomic, assign) int timeIndex;
@property (strong,nonatomic) NSTimer *timer;


//Func
@property(nonatomic,strong) YfSession *yfSession;
@property(nonatomic,assign) YfSessionState rtmpSessionState;
@property (nonatomic,strong) CTCallCenter *callCenter;
@property (nonatomic, strong) NSMutableArray *registeredNotifications;

@end

@implementation YFRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.isVertical) {
        //横屏旋转90度
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isVertical"];
    }else{
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"isVertical"];
    }
    
    [self setParameter];
    [self setupSubView];
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [filePath stringByAppendingPathComponent:@"test.flv"];
    
    [self.yfSession startRtmpSessionWithURL:filePath andStreamKey:@"flv"];
    
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(display:) userInfo:nil repeats:YES];
}

- (void)setParameter{
    self.registeredNotifications = [[NSMutableArray alloc] init];
    [self registerApplicationObservers];
    [self detectCall];
    UIPinchGestureRecognizer *ping = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    [self.view addGestureRecognizer:ping];
}

- (void) display:(CADisplayLink*)link{
    
    self.timeIndex ++;
    int sec = self.timeIndex%60;
    int min = self.timeIndex/60;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipTitle.text = [NSString stringWithFormat:@"录播中 %02d:%02d",min,sec];
    });
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

//缩放
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.yfSession) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view];
        [self.yfSession focusAtPoint:point];
    }
}

- (void)connectionStatusChanged:(YfSessionState) state{
    switch(state) {
        case YfSessionStateNone: {
            _rtmpSessionState = YfSessionStateNone;
            NSLog(@"YfSessionStateNone");
        }
            break;
        case YfSessionStatePreviewStarted: {
            _rtmpSessionState = YfSessionStatePreviewStarted;
            
            NSLog(@"初始化完成");
        }
            break;
        case YfSessionStateStarting: {
            _rtmpSessionState = YfSessionStateStarting;
            
            NSLog(@"马上开始...");
        }
            break;
        case YfSessionStateStarted: {
            _rtmpSessionState = YfSessionStateStarted;
            [XXManager sharedManager].is_facing_tracking = YES;
            self.yfSession.isHeadPhonesPlay = NO;
            NSLog(@"连接成功，录制开始");
        }
            break;
        case YfSessionStateEnded: {
            _rtmpSessionState = YfSessionStateEnded;
        }
            break;
            break;
        default:
            break;
    }
}

- (void)zoom:(UIPinchGestureRecognizer *)ping{
    if (self.yfSession) {
        [self.yfSession.videoCamera SetVideoZoom:ping.scale];
    }
}

- (void)unregisterApplicationObservers
{
    for (NSString *name in self.registeredNotifications) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:name
                                                      object:nil];
    }
}

- (void)registerApplicationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self.registeredNotifications addObject:UIApplicationWillEnterForegroundNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [self.registeredNotifications addObject:UIApplicationDidBecomeActiveNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [self.registeredNotifications addObject:UIApplicationWillResignActiveNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [self.registeredNotifications addObject:UIApplicationDidEnterBackgroundNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    [self.registeredNotifications addObject:UIApplicationWillTerminateNotification];
}

- (void)applicationDidBecomeActive{}

- (void)applicationWillResignActive{}

- (void)applicationWillEnterForeground
{
    NSLog(@"%s",__func__);
    //停止/保存录制
    [self popSaveView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)applicationDidEnterBackground{
    NSLog(@"%s",__func__);
    //录制停止时已保存在documents中
    [self.timer invalidate];
    if (self.yfSession) {
        [self.yfSession shutdownRtmpSession];
    }
}

- (void)applicationWillTerminate{}

- (void)detectCall{
    
    __weak typeof(self)weakSelf = self;
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall *call){
        
        if (call.callState == CTCallStateDisconnected) {
            NSLog(@"挂掉电话了");
            if (weakSelf.yfSession) {
                //显示保存动画
                [weakSelf popSaveView];
            }
        }else if (call.callState == CTCallStateConnected){
            NSLog(@"接电话了");
        }else if (call.callState == CTCallStateIncoming){
            NSLog(@"来电话了");
            if (weakSelf.yfSession) {
                [weakSelf.yfSession endRtmpSession];
            }
        }
        else if (call.callState == CTCallStateDialing){
            
            NSLog(@"call is dialling");
        }
    };
}

- (void)setupSubView{
    __weak typeof(self)weakSelf = self;
    [self.bgImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(20);
        make.top.equalTo(weakSelf.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(160, 30));
    }];
    
    [self.tipTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.bgImageview).offset(20);
        make.centerY.equalTo(weakSelf.bgImageview);
        make.size.mas_equalTo(CGSizeMake(120, 20));
    }];
    
    [self.switchCamera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.bgImageview.mas_right).offset(20);
        make.centerY.equalTo(weakSelf.bgImageview);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    
    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-10);
        make.centerY.equalTo(weakSelf.bgImageview);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    
    [self.setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(20);
        make.bottom.equalTo(weakSelf.view).offset(-10);
        make.size.mas_equalTo(CGSizeMake(47, 47));
    }];
    
    [self.settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view);
        make.height.mas_equalTo(300);
    }];
    
    [self.beautyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view);
        make.height.mas_equalTo(150);
    }];
    
    [self.arView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view);
        make.height.mas_equalTo(200);
    }];
    
    [self.waterMark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view);
        make.height.mas_equalTo(200);
    }];
}

-(void)dealloc{
    
    [self unregisterApplicationObservers];
    [self.yfSession.previewView removeFromSuperview];
    [self.yfSession endRtmpSession];
    self.yfSession = nil;
    NSLog(@"releaseRtmpSession");
    NSLog(@"销毁了 %s",__FUNCTION__);
}

//退出录制界面
- (void)exitRecord:(UIButton *)sender{
    [self.timer invalidate];
    self.timer = nil;
    [self.yfSession.videoCamera removeLogo];
    [self.yfSession shutdownRtmpSession];
    [self.yfSession releaseRtmpSession];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchCameraState:(UIButton *)sender{
    if (sender.selected) {
        sender.selected = NO;
        self.yfSession.cameraState = YfCameraStateFront;
    }else{
        sender.selected = YES;
        self.yfSession.cameraState = YfCameraStateBack;
    }
}

- (void)popSaveView{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"录制完成" preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    // Add the actions.
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didClickSetBtn:(UIButton *)sender{
    sender.alpha = 0;
    self.settingView.alpha = 0.8;
}

#pragma mark 懒加载
- (UIImageView *)bgImageview{
    if (!_bgImageview) {
        _bgImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time"]];
        [self.view addSubview:_bgImageview];
    }
    return _bgImageview;
}

- (UILabel *)tipTitle{
    if (!_tipTitle) {
        _tipTitle = [[UILabel alloc] init];
        _tipTitle.text = @"录制中  00:00";
        _tipTitle.textColor = [UIColor whiteColor];
        _tipTitle.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:_tipTitle];
    }
    return _tipTitle;
}

- (UIButton *)switchCamera{
    if (!_switchCamera) {
        _switchCamera = [[UIButton alloc] init];
        [_switchCamera setBackgroundImage:[UIImage imageNamed:@"camera1"] forState:UIControlStateNormal];
        [_switchCamera setBackgroundImage:[UIImage imageNamed:@"camera2"] forState:UIControlStateSelected];
        [_switchCamera addTarget:self action:@selector(switchCameraState:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_switchCamera];
    }
    return _switchCamera;
}

- (UIButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [[UIButton alloc] init];
        [_exitBtn setBackgroundImage:[UIImage imageNamed:@"close1"] forState:UIControlStateNormal];
        [_exitBtn setBackgroundImage:[UIImage imageNamed:@"close2"] forState:UIControlStateHighlighted];
        [_exitBtn addTarget:self action:@selector(exitRecord:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_exitBtn];
    }
    return _exitBtn;
}

- (UIButton *)setBtn{
    if (!_setBtn) {
        _setBtn = [[UIButton alloc] init];
        [_setBtn setBackgroundImage:[UIImage imageNamed:@"set1"] forState:UIControlStateNormal];
        [_setBtn setBackgroundImage:[UIImage imageNamed:@"set2"] forState:UIControlStateHighlighted];
        [_setBtn addTarget:self action:@selector(didClickSetBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_setBtn];
    }
    return _setBtn;
}

- (YfSession *)yfSession{
    if (!_yfSession) {
        
        if (self.isVertical) {
            NSLog(@"竖屏推流");
            _yfSession = [[YfSession alloc] initWithVideoSize:CGSizeMake(360, 640) sessionPreset:AVCaptureSessionPresetiFrame960x540 frameRate:24 bitrate:800*1000 bufferTime:2 isUseUDP:NO isDropFrame:YES YfOutPutImageOrientation:YfOutPutImageOrientationNormal isOnlyAudioPushBuffer:NO audioRecoderError:nil isOpenAdaptBitrate:YES];
            
        }else{
            NSLog(@"横屏推流");
            _yfSession = [[YfSession alloc] initWithVideoSize:CGSizeMake(640, 360) sessionPreset:AVCaptureSessionPresetiFrame960x540 frameRate:24 bitrate:800*1000 bufferTime:2 isUseUDP:NO isDropFrame:YES YfOutPutImageOrientation:YfOutPutImageOrientationLandLeftFullScreen isOnlyAudioPushBuffer:NO audioRecoderError:nil isOpenAdaptBitrate:YES];
            
        }
        [self.view insertSubview:_yfSession.previewView atIndex:0];
        
        if (!self.isVertical) {
            //横屏
            __weak typeof(self)weakSelf = self;
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            [_yfSession.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(weakSelf.view);
                make.width.mas_equalTo(screenSize.width);
                make.height.mas_equalTo(screenSize.height);
            }];
            //旋转 -90度
            [_yfSession.previewView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        }
        //设置心形手势的bundle文件名
        [XXManager sharedManager].heartName = @"heart_iloveu.bundle";
        _yfSession.delegate = self;
        //人脸检测和手势开始设置为NO，等预览层加载好后，再设为YES
        [XXManager sharedManager].is_facing_tracking = NO;
        [XXManager sharedManager].is_heartGesture = NO;
        
        NSString *png = [[NSBundle mainBundle] pathForResource:@"shuiyin1" ofType:@"png"];
//        [_yfSession drawImageTexture:png pointSize:YfSessionLogoPositionrightUp];
        [_yfSession.videoCamera drawImageTexture:png PointSize:YfSessionCameraLogoPostitionrightUp];
    }
    return _yfSession;
}

- (YFRecordSettingView *)settingView{
    if (!_settingView) {
        __weak typeof(self)weakSelf = self;
        _settingView = [[YFRecordSettingView alloc] initWithCallBack:^(UIButton *icon,UIButton *btn) {
            //对数据做处理
            NSString *title = btn.titleLabel.text;
            if ([title containsString:@"美颜"]) {
                weakSelf.beautyView.alpha = 0.8;
                weakSelf.settingView.alpha = 0;
            }else if ([title containsString:@"AR直播"]){
                weakSelf.arView.alpha = 0.8;
                weakSelf.settingView.alpha = 0;
            }else if ([title containsString:@"水印"]){
                weakSelf.waterMark.alpha = 0.8;
                weakSelf.settingView.alpha = 0;
            }else if ([title containsString:@"耳返"]){
                if (!btn.selected) {
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"耳返/开" forState:UIControlStateNormal];
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"耳返/关" forState:UIControlStateNormal];
                }
            }else if ([title containsString:@"降噪"]){
                if (!btn.selected) {
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"降噪/开" forState:UIControlStateNormal];
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"降噪/关" forState:UIControlStateNormal];
                }
            }else if ([title containsString:@"静音"]){
                if (!btn.selected) {
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"静音/开" forState:UIControlStateNormal];
                    weakSelf.yfSession.IsAudioOpen = YES;
                    
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"静音/关" forState:UIControlStateNormal];
                    weakSelf.yfSession.IsAudioOpen = NO;
                }
            }else if ([title containsString:@"日志"]){
                if (!btn.selected) {
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"日志/开" forState:UIControlStateNormal];
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"日志/关" forState:UIControlStateNormal];
                }
            }else if ([title containsString:@"镜像"]){
                if (!btn.selected) {
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"镜像/关" forState:UIControlStateNormal];
                    weakSelf.yfSession.isPlayerCameraMirror = NO;
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"镜像/开" forState:UIControlStateNormal];
                    weakSelf.yfSession.isPlayerCameraMirror = YES;
                }
            }

        }];
        
        _settingView.cancel = ^(){
            
            weakSelf.setBtn.alpha = 1;
            weakSelf.settingView.alpha = 0;
        };
        _settingView.alpha = 0;
        _settingView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_settingView];
    }
    return _settingView;
}

- (YFBeautyView *)beautyView{
    if (!_beautyView) {
        _beautyView = [[YFBeautyView alloc] init];
        _beautyView.backgroundColor = [UIColor blackColor];
        _beautyView.alpha = 0;
        __weak typeof(self)weakSelf = self;
        _beautyView.callBack = ^(int i){
            [XXManager sharedManager].beautyLever = i * 0.2;
        };
        _beautyView.cancel = ^(){
            weakSelf.beautyView.alpha = 0;
            weakSelf.setBtn.alpha = 1;
        };
        
        [self.view addSubview:_beautyView];
    }
    return _beautyView;
}

- (YFARView *)arView{
    if (!_arView) {
        __weak typeof(self)weakSelf = self;
        _arView = [[YFARView alloc] init];
        _arView.callBack = ^(int i){
            //ar动画回调
            if (i == 0) {
                [XXManager sharedManager].isOnlyBeauty = YES;
            }else{
                [XXManager sharedManager].isOnlyBeauty = NO;
                NSString *path = [[NSBundle mainBundle] pathForResource:weakSelf.bundleArr[i-1] ofType:nil];
                [[XXManager sharedManager] reLoadItem:path];
            }
        };
        _arView.cancel = ^(){
            weakSelf.arView.alpha = 0;
            weakSelf.setBtn.alpha = 1;
        };
        _arView.alpha = 0;
        _arView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_arView];
    }
    return _arView;
}

- (YFWaterMarkView *)waterMark{
    if (!_waterMark) {
        __weak typeof(self)weakSelf = self;
        _waterMark = [[YFWaterMarkView alloc] init];
        
        _waterMark.callBack = ^(int i){
            if (i == 0) {
                [weakSelf.yfSession.videoCamera removeLogo];
            }else{
                
                if (i>4) {
                    return ;
                }
                NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"shuiyin%d",i] ofType:@"png"];
                [weakSelf.yfSession.videoCamera drawImageTexture:filePath PointSize:YfSessionCameraLogoPostitionrightUp];
            }
        };
        
        _waterMark.cancel = ^(){
            weakSelf.waterMark.alpha = 0;
            weakSelf.setBtn.alpha = 1;
        };
        _waterMark.alpha = 0;
        _waterMark.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_waterMark];
    }
    return _waterMark;
}

- (NSArray *)bundleArr{
    if (!_bundleArr) {
        _bundleArr = @[@"PrincessCrown.bundle",@"BeagleDog.bundle",@"YellowEar.bundle",@"Deer.bundle",@"HappyRabbi.bundle",@"hartshorn.bundle",@"Mood.bundle",];
    }
    return _bundleArr;
}

@end
