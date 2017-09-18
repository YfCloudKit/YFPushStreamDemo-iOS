//
//  YFLiveViewController.m
//  YFPlayerPushStreaming-Demo
//
//  Created by apple on 3/31/17.
//  Copyright © 2017 YunFan. All rights reserved.
//

#import "YFLiveViewController.h"
#import "Masonry.h"
#import "AFNetworking.h"
#import <YFMediaPlayerPushStreaming/YFMediaPlayerPushStreaming.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "YFLiveSettingView.h"
#import "YFBeautyView.h"
#import "YFARView.h"
#import "YFWaterMarkView.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <YFMediaPlayerPushStreaming/YfSessionCamera.h>
#import <YFMediaPlayerPushStreaming/XXManager.h>

static bool openparam = 0;

@interface YFLiveViewController ()<YfSessionDelegate>
//UI
@property (nonatomic, strong) UIButton *exitBtn;
@property (nonatomic, strong) UIImageView *bgImageview;
@property (nonatomic, strong) UILabel *tipTitle;
@property (nonatomic, strong) UIButton *switchCamera;
@property (nonatomic, strong) UIButton *setBtn;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) YFLiveSettingView *settingView;
@property (nonatomic, strong) YFBeautyView *beautyView;
@property (nonatomic, strong) YFARView *arView;
@property (nonatomic, strong) YFWaterMarkView *waterMark;
@property (nonatomic, strong) NSArray *bundleArr;
@property (nonatomic, assign) int timeIndex;
@property (strong,nonatomic) NSTimer *timer;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *headBtn;

//Func
//直播关键类
@property(nonatomic,strong) YfSession *yfSession;
//网络判断管理类
@property(nonatomic,strong) AFNetworkReachabilityManager *reachabilityMannger;
//推流状态
@property(nonatomic,assign) YfSessionState rtmpSessionState;
//是否手动点击关闭推流
@property(nonatomic,assign) BOOL isManualCloseLive;
//重推流的最大次数
@property (nonatomic, assign) NSInteger retryPushStreamCount;
//来电
@property (nonatomic,strong) CTCallCenter *callCenter;

@property (nonatomic, strong) NSMutableArray *registeredNotifications;

@property (nonatomic, assign) BOOL isPushed;

//功能测试区域
@property (nonatomic, strong) UIButton *testBtn;
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) UIButton *testBtn2;

@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UIView *filterView;

#pragma mark 局部美颜参数
//[-360, 360]色温
@property (nonatomic, strong) UISlider *RotateHue;
@property (nonatomic, strong) UISlider *Saturation;
@property (nonatomic, strong) UISlider *Brightness;
@property (nonatomic, strong) UISlider *Exposureness;
@property (nonatomic, strong) UISlider *Temperatureness;
@property (nonatomic, strong) UISlider *Blurness;

#pragma mark 全局美颜参数

@property (nonatomic, strong) UISlider *redLevel;
@property (nonatomic, strong) UISlider *BlurLevel;
@property (nonatomic, strong) UISlider *globalSaturation;
@property (nonatomic, strong) UISlider *globalBrightNess;

@property (nonatomic, strong) UIButton *cameraFilter;
@property (nonatomic, strong) UIButton *INSBtn;

@property (nonatomic, assign) int index;
@property (nonatomic, assign) int index2;

@property (nonatomic, strong) UILabel *labelrotateHue;
@property (nonatomic, strong) UILabel *labelSaturation;
@property (nonatomic, strong) UILabel *labelBrightness;
@property (nonatomic, strong) UILabel *labelExposureness;
@property (nonatomic, strong) UILabel *labelTemperatureness;
@property (nonatomic, strong) UILabel *labelBlurness;

@property (nonatomic, strong) UILabel *labelRedLevel;
@property (nonatomic, strong) UILabel *labelBlurLevel;
@property (nonatomic, strong) UILabel *labelglobalSaturation;
@property (nonatomic, strong) UILabel *labelglobalBrightNess;

@property (nonatomic, strong) UIButton *test;

@property (nonatomic, strong) UIView *logView;

@property (nonatomic, strong) UILabel *SRspeedLab;
@property (nonatomic, strong) UILabel *runInfoLab;
@property (nonatomic, strong) UILabel *adaptBitrate;
@end

@implementation YFLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setParameter];
    
    
    if (!self.isVertical) {
        //横屏直播  旋转90度
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"isVertical"];
    }else{
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"isVertical"];
    }
    
    [self setupSubView];
    [self gainDisplayLink];
    
    //测试代码
//    self.test = [[UIButton alloc] initWithFrame:CGRectMake(10, 300, 120, 30)];
//    [self.test setTitle:@"测试按钮" forState:UIControlStateNormal];
//    [self.test setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.test setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
//    [self.test addTarget:self action:@selector(test11:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.test];
    self.adaptBitrate = [[UILabel alloc] init];
    
    self.adaptBitrate.frame = CGRectMake(10, 200, 120, 40);
    
    [self.view addSubview:self.adaptBitrate];
    
}

static int is = 0;

- (void)test11:(UIButton *)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        for (int i = 0; i < 500000; ++i) {
            is++;
            NSString *str = [NSString stringWithFormat:@"test%d",is];
        }
        
        [self performSelector:@selector(test11:) withObject:nil afterDelay:2];
        
    });
    NSLog(@"....");
}

- (void)setParameter{
    if (self.kbps < 400) {
        self.kbps = 400;
    }
    if (self.fps < 10) {
        self.fps = 10;
    }
    
    self.isPushed = NO;
    self.registeredNotifications = [[NSMutableArray alloc] init];
    self.retryPushStreamCount = 5;
    self.reachabilityMannger = [AFNetworkReachabilityManager sharedManager];
    [self.reachabilityMannger startMonitoring];
    [self networkReachabilityStatusChange];
    [self setupYfSession];
    [self registerApplicationObservers];
    [self detectCall];
    UIPinchGestureRecognizer *ping = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    [self.view addGestureRecognizer:ping];
    
    if (openparam) {
        [self addSlider];
        [self addLabel];
    }
}

- (void)addLabel{
    
    self.labelrotateHue = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 20)];
    self.labelrotateHue.text = @"色温";
    self.labelrotateHue.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelrotateHue];
    
    self.labelSaturation = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 100, 20)];
    self.labelSaturation.text = @"饱和度";
    self.labelSaturation.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelSaturation];
    
    self.labelBrightness = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 100, 20)];
    self.labelBrightness.text = @"明亮度";
    self.labelBrightness.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelBrightness];
    
    self.labelExposureness = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 20)];
//    self.labelExposureness.text = @"曝光度";
    self.labelExposureness.text = @"红润";
    self.labelExposureness.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelExposureness];
    
    self.labelTemperatureness = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 100, 20)];
    self.labelTemperatureness.text = @"白平衡";
    self.labelTemperatureness.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelTemperatureness];
    
    self.labelBlurness = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 100, 20)];
    self.labelBlurness.text = @"磨皮";
    self.labelBlurness.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelBlurness];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 260, 20)];
    line.textColor = [UIColor whiteColor];
    line.text = @"以下参数在全局美颜下生效";
    [self.sliderView addSubview:line];
    
    self.labelRedLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 210, 100, 20)];
    self.labelRedLevel.text = @"红润";
    self.labelRedLevel.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelRedLevel];
    
    self.labelBlurLevel = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, 100, 20)];
    self.labelBlurLevel.text = @"磨皮";
    self.labelBlurLevel.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelBlurLevel];
    
    self.labelglobalSaturation = [[UILabel alloc] initWithFrame:CGRectMake(0, 270, 100, 20)];
    self.labelglobalSaturation.text = @"饱和度";
    self.labelglobalSaturation.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelglobalSaturation];
    
    self.labelglobalBrightNess = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, 100, 20)];
    self.labelglobalBrightNess.text = @"明亮度";
    self.labelglobalBrightNess.textColor = [UIColor whiteColor];
    [self.sliderView addSubview:self.labelglobalBrightNess];
    
}

- (void)gainDisplayLink{
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(display) userInfo:nil repeats:YES];
}

- (void) display{
    
    self.timeIndex ++;
    int sec = self.timeIndex%60;
    int min = self.timeIndex/60;
    int adaptBitrate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"adaptBitrate"] intValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipTitle.text = [NSString stringWithFormat:@"直播中 %02d:%02d",min,sec];
        self.adaptBitrate.text = [NSString stringWithFormat:@"%d",adaptBitrate];
    });
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)yfSessionSendSpeed:(CGFloat)send AndReceiveSpeed:(CGFloat)receiveSpeed{
//    NSLog(@"send = %f,recive = %f",send,receiveSpeed);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.SRspeedLab.text = [NSString stringWithFormat:@"send:%f receive:%f",send,receiveSpeed];
    });
    
}

- (void)yfSessionRunInfo:(NSString *)str{
//    NSLog(@"%@",str);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.runInfoLab.text = str;
    });   
}

- (void)networkReachabilityStatusChange{
    __weak typeof(self) weakSelf = self;
    [self.reachabilityMannger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *result = @"";
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                result = @"未知网络";
                break;
            case AFNetworkReachabilityStatusNotReachable:
                result = @"无网络";
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                result = @"WAN";
                [weakSelf.yfSession ShutErrorRtmpSession];
                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [weakSelf.yfSession startRtmpSessionWithRtmpURL:weakSelf.urlString];
//                });
                
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                result = @"WIFI";
                break;
            default:
                break;
        }
        NSLog(@"--%s current network status:%@",__FUNCTION__,result);
        //[weakSelf restorePushStream:status];
    }];
}

- (void)zoom:(UIPinchGestureRecognizer *)ping{
    if (self.yfSession) {
        [self.yfSession.videoCamera SetVideoZoom:ping.scale];
    }
}

- (void)detectCall{
    
    __weak typeof(self)weakSelf = self;
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall *call){
        
        if (call.callState == CTCallStateDisconnected) {
            NSLog(@"挂掉电话了");
            if (weakSelf.yfSession) {
                [weakSelf.yfSession startRtmpSessionWithRtmpURL:weakSelf.urlString];
            }
            
        }else if (call.callState == CTCallStateConnected){
            NSLog(@"接电话了");
        }else if (call.callState == CTCallStateIncoming){
            NSLog(@"来电话了");
            if (weakSelf.yfSession) {
                [weakSelf.yfSession endRtmpSession];
            }
        }else if (call.callState == CTCallStateDialing){
            
            NSLog(@"call is dialling");
        }
    };
}

/**
 *  恢复推流
 *
 *  @param status 网络状态
 */
//e1b0a28155adaf79ac302cc1e097dc634c465879
- (void)restorePushStream:(AFNetworkReachabilityStatus)status{
    if (status == AFNetworkReachabilityStatusNotReachable) {
        NSLog(@"Network error. Please check your network connection.");
        //TODO 通知云帆sdk,当前网络无法连接
        if(self.yfSession && self.urlString){
            [self.yfSession ShutErrorRtmpSession];//立即收到推流错误的回调
            NSLog(@"%s ShutErrorRtmpSession",__FUNCTION__);
        }
    }else{
        NSLog(@"%s rtmpSessionState=%zd",__FUNCTION__ , _rtmpSessionState);
        //上一次推流错误，网络恢复的时候 重新推流
        if (self.urlString && self.yfSession && _rtmpSessionState == YfSessionStateError) {
            NSLog(@"%s 重新推流 startRtmpSessionWithRtmpURL",__FUNCTION__);
            [self.yfSession startRtmpSessionWithRtmpURL:self.urlString];
        }
    }
}

/**
 *  重试推流
 */
-(void)retryPushStream{
    self.retryPushStreamCount--;
    if (self.retryPushStreamCount <= 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:NSLocalizedString(@"There seems to be a problem! Kindly check your connection and restart your stream.", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.yfSession && self.urlString) {
                [self.yfSession startRtmpSessionWithRtmpURL:self.urlString];
            }
        });
    }
}

#pragma mark - 云帆推流连接回调通知

- (void)connectionStatusChanged:(YfSessionState) state{
    switch(state) {
        case YfSessionStateNone: {
            _rtmpSessionState = YfSessionStateNone;
            NSLog(@"YfSessionStateNone");
        }
            break;
        case YfSessionStatePreviewStarted: {
            _rtmpSessionState = YfSessionStatePreviewStarted;
            
            [XXManager sharedManager].is_facing_tracking = YES;
//            _yfSession.is_heartGesture = NO;
            //_yfSession.isHeadPhonesPlay = NO;
            //开始推流
            [self.yfSession startRtmpSessionWithRtmpURL:self.urlString];
            NSLog(@"初始化完成");
        }
            break;
        case YfSessionStateStarting: {
            _rtmpSessionState = YfSessionStateStarting;
            NSLog(@"正在连接流服务器...");
            
            dispatch_async(dispatch_get_main_queue(), ^{
               self.stateLabel.text = @"正在连接服务器..";
            });
        }
            break;
        case YfSessionStateStarted: {
            _rtmpSessionState = YfSessionStateStarted;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.stateLabel.text = @"连接成功，推流开始";
            });
            NSLog(@"连接成功，推流开始");
            self.retryPushStreamCount = 5;
        }
            break;
        case YfSessionStateEnded: {
            _rtmpSessionState = YfSessionStateEnded;
        }
            break;
        case YfSessionStateError: {
            _rtmpSessionState = YfSessionStateError;
            NSLog(@"连接流服务器出错");
            if (self.isManualCloseLive) {
                if (_yfSession) {
                    [_yfSession releaseRtmpSession];//停止rtmp session，释放资源，不会触发rtmp session结束通知
                    NSLog(@"%s releaseRtmpSession",__FUNCTION__);
                }
            }else{
                if (self.yfSession && self.urlString) {
                    [self.yfSession shutdownRtmpSession]; //停止rtmp session，不释放资源
                    NSLog(@"%s shutdownRtmpSession",__FUNCTION__);
                }
            }
            if (self.reachabilityMannger.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable) {
                NSLog(@"%s 继续重试推流 retryPushStream...",__FUNCTION__);
                 [self retryPushStream];//继续重试推流（5次机会）
            }
        }
            break;
        default:
            break;
    }
}

- (void)yfsessionUploadSpeed:(int32_t)uploadSpeed{
    
    NSLog(@"speed: %d",uploadSpeed);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.speedLabel.text = [NSString stringWithFormat:@"Speed: %dkbps",uploadSpeed];
    });
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

- (void)applicationDidBecomeActive
{
    NSLog(@"%s",__func__);
    
}

- (void)applicationWillResignActive{
    NSLog(@"%s",__func__);
}



- (void)applicationWillEnterForeground
{
    [self gainDisplayLink];
    [self.yfSession startRtmpSessionWithRtmpURL:self.urlString];
    
    NSLog(@"%s",__func__);
    //检测是否有耳机
    BOOL isHead = [self isHeadsetPluggedIn];
    
    if (!isHead) {
        //如果用户进入后台，拔掉耳机
        if (self.yfSession.isHeadPhonesPlay) {
            self.yfSession.isHeadPhonesPlay = NO;
            if (self.headBtn) {
                self.headBtn.selected = NO;
                [self.headBtn setTitle:@"耳返/关" forState:UIControlStateNormal];
            }
        }
    }

}

- (void)applicationDidEnterBackground{
    NSLog(@"%s",__func__);
    
    [self.timer invalidate];
    self.timer = nil;
    [self.yfSession shutdownRtmpSession];
}

- (void)applicationWillTerminate{
    NSLog(@"%s",__func__);
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

- (void)setupYfSession{
    if (!_yfSession) {
        
        if (self.isVertical) {
            NSLog(@"竖屏推流");
            _yfSession = [[YfSession alloc] initWithVideoSize:CGSizeMake(540, 960) sessionPreset:AVCaptureSessionPresetiFrame960x540 frameRate:20 bitrate:800*1000 bufferTime:2 isUseUDP:self.transportStyle isDropFrame:YES YfOutPutImageOrientation:YfOutPutImageOrientationNormal isOnlyAudioPushBuffer:NO audioRecoderError:^(NSString *error, OSStatus status) {
                [self popMessageView:@"打开音频设备失败"];
                
            } isOpenAdaptBitrate:YES];
            
            
        }else{
            NSLog(@"横屏推流");
            _yfSession = [[YfSession alloc] initWithVideoSize:CGSizeMake(960, 540) sessionPreset:AVCaptureSessionPresetiFrame960x540 frameRate:20 bitrate:800*1000 bufferTime:2  isUseUDP:self.transportStyle isDropFrame:YES YfOutPutImageOrientation:YfOutPutImageOrientationLandLeftFullScreen isOnlyAudioPushBuffer:NO audioRecoderError:^(NSString *error, OSStatus status) {
                [self popMessageView:@"打开音频设备失败"];
            } isOpenAdaptBitrate:YES];
            
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
            
            [_yfSession.previewView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        }
        XXManager *manager = [XXManager sharedManager];
        manager.open = YES;
        
        //设置心形手势的bundle文件名
        manager.heartName = @"heart_iloveu.bundle";
        _yfSession.delegate = self;
        //人脸检测和手势开始设置为NO，等预览层加载好后，再设为YES
        manager.is_facing_tracking = NO;
        manager.is_heartGesture = NO;
        _yfSession.isHeadPhonesPlay = NO;
        [_yfSession.videoCamera switchBeautyFilter:YfSessionCameraBeautifulFilterLocalSkinBeauty];
//        [_yfSession setupFilter:YfSessionFilterFishEye];
//        _yfSession.isBeautify = NO;
//        _yfSession.isOnlyBeauty = YES;
        //默认为YES
        _yfSession.IsAudioOpen = YES;
        //加载水印logo，切换时仍然调用此方法 退出直播时需调用- (void)releaseImageTexture;释放
        NSString *png = [[NSBundle mainBundle] pathForResource:@"shuiyin1" ofType:@"png"];
        [_yfSession.videoCamera drawImageTexture:png PointSize:YfSessionCameraLogoPostitionrightUp];
        
    }
}

- (void)popMessageView:(NSString *)meg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:meg preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the actions.
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    // Add the actions.
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//退出
- (void)exitLive:(UIButton *)sender{
    
    //移除logo
    [self.timer invalidate];
    self.timer = nil;
    [self.yfSession.videoCamera removeLogo];
    [self.yfSession shutdownRtmpSession];
    [self.yfSession releaseRtmpSession];
    self.yfSession = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}
//竖屏布局
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
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(10);
        make.bottom.equalTo(weakSelf.view).offset(-87);
        make.size.mas_equalTo(CGSizeMake(160, 20));
    }];
    
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(10);
        make.bottom.equalTo(weakSelf.stateLabel.mas_top).offset(-10);
        make.size.mas_equalTo(CGSizeMake(160, 20));
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

    [self.testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(80);
        make.size.mas_equalTo(CGSizeMake(120, 60));
    }];

    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(200);
        make.size.mas_equalTo(CGSizeMake(140, 140));
    }];
    
    if (openparam) {
        
        [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(weakSelf.view);
            make.top.equalTo(weakSelf.view).offset(130);
            make.size.mas_equalTo(CGSizeMake([UIScreen mainScreen].bounds.size.width, 350));
        }];
    }
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.testBtn.mas_right);
        make.top.equalTo(weakSelf.view).offset(80);
        make.size.mas_equalTo(CGSizeMake(120, 60));
    }];
    
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(130);
        make.size.mas_equalTo(CGSizeMake([UIScreen mainScreen].bounds.size.width, 350));
    }];
    
    [self.testBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-30);
        make.top.equalTo(weakSelf.view).offset(80);
        make.size.mas_equalTo(CGSizeMake(120, 60));
    }];
    
    [self.logView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(120);
        make.height.mas_equalTo(300);
    }];
    
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

//聚焦
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.yfSession) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.view];
        
        CGPoint pointOfInterest = CGPointZero;
        CGSize frameSize = self.view.bounds.size;
        pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
        
        [self.yfSession focusAtPoint:pointOfInterest];
    }
    
}

- (void)didClickSetBtn:(UIButton *)sender{
    
    self.setBtn.hidden = YES;
    self.settingView.hidden = NO;
}

//static int i = 0;

- (void)didClickTest:(UIButton *)sender{
    
    if (sender.selected) {
        _yfSession.beautyType = YfSessionCameraBeautifulFilterLocalSkinBeauty;
//        int bitrate = [[self valueForKeyPath:@"self.yfSession.bitrate"] intValue];
        [_yfSession reSetFrameRate:24];
        sender.selected = NO;
    }else{
        sender.selected = YES;
//        int bitrate = [[self valueForKeyPath:@"self.yfSession.currentSpeed"] intValue];
//        NSLog(@" === %d",bitrate);
//        [_yfSession reSetFrameRate:15];
        _yfSession.beautyType = YfSessionCameraBeautifulFilterGlobalBeauty;
    }
    
//    _yfSession.beautyLever = 0;
    
//    [_yfSession switchCameraFilter:YFINSTCamera_WALDEN_FILTER];
//    _yfSession.isBeautify = !_yfSession.isBeautify ;
//    [_yfSession switchCameraFilter:(YFINSTCameraFilterType)i];
//    [_yfSession setupFilter:(YfSessionFilter)i];
//    i ++;
    
    
//        [_yfSession switchCameraFilter:YFINSTCamera_WALDEN_FILTER];
//        [_yfSession.videoCamera adjustSaturation:1.2];
//        [_yfSession.videoCamera adjustBlurness:2.0];

////        [_yfSession.videoCamera setRouGuangLevel:0.3];
////        [_yfSession.videoCamera setBlurLevel:0.5];
////        [_yfSession.videoCamera setSaturationLevel:0.5];
//        [_yfSession switchCameraFilter:YFINSTCamera_WALDEN_FILTER];
////        _yfSession.beautyType = YfSessionCameraBeautifulFilterNone;
//        

    
    
//    _yfSession.is_heartGesture = YES;
//    [self.yfSession setSharpnessLevel:0.4];
    
//    self.yfSession.isYFBeauty = NO;
////
//    self.yfSession.isBeautify = !self.yfSession.isBeautify;
//    
//    sender.selected = !sender.selected;
//    [self.yfSession setRouGuangLevel:sender.selected];
    
//    [self.yfSession setupFilter:YfSessionFilterMagicMirror];
    
//    self.yfSession.isBeautify = !self.yfSession.isBeautify;
    
    //播放段预览层放大
//    [self.yfSession setScaleX:2 Y:2 Z:1];
    
//    __weak typeof(self)weakSelf = self;
//    //参数1、间隔采集时间 2、图片数量 3、播放时间
//    [self.yfSession createGifSnapShotDelayTime:0.25 ImageCount:24 gifDelayTime:0.25 gifFileName:@"hhh.gif" gifCallBack:^(CFURLRef GifFileURL) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            CGImageSourceRef source = CGImageSourceCreateWithURL(GifFileURL, NULL);
//            //帧数
//            size_t count = CGImageSourceGetCount(source);
//            
//            NSMutableArray *tmparr = [NSMutableArray array];
//            
//            for (size_t i = 0 ; i < count; i ++) {
//                
//                //获取图像
//                CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
//                
//                //生成uiimage
//                UIImage *img = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
//                
//                [tmparr addObject:img];
//                
//                CGImageRelease(imageRef);
//            }
//            
//            CFRelease(source);
//            
//            weakSelf.imgView.animationImages = tmparr; //动画图片数组
//            weakSelf.imgView.animationDuration = 24 * 0.25; //执行一次完整动画所需的时长
//            weakSelf.imgView.animationRepeatCount = 0;  //动画重复次数
//            [weakSelf.imgView startAnimating];
//            
//        });
//        
//    }];

//    self.imgView.image = [self.yfSession snapshot];
}

#pragma mark slider方法

- (void)sliderRotateHue:(UISlider *)slider{
    [self.yfSession.videoCamera rotateHue:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelrotateHue.text = [NSString stringWithFormat:@"色温%.1f",slider.value];
    });
}

- (void)sliderSaturation:(UISlider *)slider{
    [self.yfSession.videoCamera adjustSaturation:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelSaturation.text = [NSString stringWithFormat:@"饱和度%.1f",slider.value];
    });
}

- (void)sliderbrightness:(UISlider *)slider{
    [self.yfSession.videoCamera adjustBrightness:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelBrightness.text = [NSString stringWithFormat:@"明亮度%.1f",slider.value];
    });
}

- (void)sliderExposureness:(UISlider *)slider{
//    [self.yfSession.videoCamera adjustExposureness:slider.value];
    [self.yfSession.videoCamera adjustRuddiness:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelExposureness.text = [NSString stringWithFormat:@"红润%.1f",slider.value];
    });
}

- (void)sliderTemperatureness:(UISlider *)slider{
    [self.yfSession.videoCamera adjustTemperatureness:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelTemperatureness.text = [NSString stringWithFormat:@"白平衡%.1f",slider.value];
    });
}

- (void)sliderBlurness:(UISlider *)slider{
    [self.yfSession.videoCamera adjustBlurness:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelBlurness.text = [NSString stringWithFormat:@"磨皮%.1f",slider.value];
    });
}

- (void)sliderRedLevel:(UISlider *)slider{
    [self.yfSession.videoCamera setRouGuangLevel:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelRedLevel.text = [NSString stringWithFormat:@"红润%.1f",slider.value];
    });
}

- (void)sliderBlurLevel:(UISlider *)slider{
    [self.yfSession.videoCamera setBlurLevel:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelBlurLevel.text = [NSString stringWithFormat:@"磨皮%.1f",slider.value];
    });
}

- (void)sliderGlobalSaturation:(UISlider *)slider{
    [self.yfSession.videoCamera setSaturationLevel:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelglobalSaturation.text = [NSString stringWithFormat:@"饱和度%.1f",slider.value];
    });
}

- (void)sliderGlobalBrightNess:(UISlider *)slider{
    [self.yfSession.videoCamera setBrightNessLevel:slider.value];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.labelglobalBrightNess.text = [NSString stringWithFormat:@"明亮度%.1f",slider.value];
    });
}

- (void)addSlider{
    [self.sliderView addSubview:self.RotateHue];
    [self.sliderView addSubview:self.Saturation];
    [self.sliderView addSubview:self.Brightness];
    [self.sliderView addSubview:self.Exposureness];
    [self.sliderView addSubview:self.Temperatureness];
    [self.sliderView addSubview:self.Blurness];
    
    [self.sliderView addSubview:self.redLevel];
    [self.sliderView addSubview:self.BlurLevel];
    [self.sliderView addSubview:self.globalSaturation];
    [self.sliderView addSubview:self.globalBrightNess];
    
    [self.filterView addSubview:self.cameraFilter];
    [self.filterView addSubview:self.INSBtn];
}

- (void)switchView:(UIButton *)sender{
    
    if (sender.selected) {
        sender.selected = NO;
        self.sliderView.hidden = NO;
        self.filterView.hidden = YES;
    }else{
        sender.selected = YES;
        self.sliderView.hidden = YES;
        self.filterView.hidden = NO;
    }
    
}

- (void)onOffBeauty:(UIButton *)sender{
    
    if (sender.selected) {
        sender.selected = NO;
        [XXManager sharedManager].open = YES;
    }else{
        sender.selected = YES;
        [XXManager sharedManager].open = NO;
    }
    
}

-(void)dealloc{
    
    [self unregisterApplicationObservers];
    [self.reachabilityMannger stopMonitoring];
    self.callCenter = nil;

    NSLog(@"%s",__FUNCTION__);
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
        _tipTitle.text = @"直播中  00:00";
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
        [_exitBtn addTarget:self action:@selector(exitLive:) forControlEvents:UIControlEventTouchUpInside];
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

- (UILabel *)stateLabel{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = [UIColor cyanColor];
        _stateLabel.text = @"正在推流";
        [self.view addSubview:_stateLabel];
    }
    return _stateLabel;
}

- (UILabel *)speedLabel{
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] init];
        _speedLabel.textColor = [UIColor cyanColor];
        _speedLabel.text = @"Speed:";
        [self.view addSubview:_speedLabel];
    }
    return _speedLabel;
}

- (YFLiveSettingView *)settingView{
    if (!_settingView) {
        __weak typeof(self)weakSelf = self;
        _settingView = [[YFLiveSettingView alloc] initWithCallBack:^(UIButton *icon,UIButton *btn) {
            NSString *title = btn.titleLabel.text;
            if ([title isEqualToString:@"美颜"]) {
                weakSelf.beautyView.hidden = NO;
                weakSelf.settingView.hidden = YES;
            }else if ([title isEqualToString:@"AR直播"]){
                weakSelf.arView.hidden = NO;
                weakSelf.settingView.hidden = YES;
            }else if ([title isEqualToString:@"水印"]){
                weakSelf.waterMark.hidden = NO;
                weakSelf.settingView.hidden = YES;
            }else if ([title containsString:@"耳返"]){
                if(!btn.selected){
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"耳返/开" forState:UIControlStateNormal];
                    weakSelf.headBtn = btn;
                    weakSelf.yfSession.isHeadPhonesPlay = YES;
                    NSLog(@"耳返/开");
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"耳返/关" forState:UIControlStateNormal];
                    weakSelf.headBtn = btn;
                    weakSelf.yfSession.isHeadPhonesPlay = NO;
                    NSLog(@"耳返/关");
                }
                
            }else if ([title containsString:@"降噪"]){
                if(!btn.selected){
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"降噪/关" forState:UIControlStateNormal];
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"降噪/开" forState:UIControlStateNormal];
                }
            }else if ([title containsString:@"镜像"]){
                if(!btn.selected){
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
                
            }else if ([title isEqualToString:@"H.265"]){
                
            }else if ([title containsString:@"适应码率"]){
                if(!btn.selected){
                    btn.selected = YES;
                    icon.selected = YES;
                    weakSelf.yfSession.isOpenAdaptaBitrate = NO;
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    weakSelf.yfSession.isOpenAdaptaBitrate = YES;
                }
            }else if ([title containsString:@"静音"]){
                if(!btn.selected){
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"静音/开" forState:UIControlStateNormal];
                    weakSelf.yfSession.IsAudioOpen = NO;
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"静音/关" forState:UIControlStateNormal];
                    weakSelf.yfSession.IsAudioOpen = YES;
                }
                
            }else if ([title containsString:@"日志"]){
                if(!btn.selected){
                    btn.selected = YES;
                    icon.selected = YES;
                    [btn setTitle:@"日志/开" forState:UIControlStateNormal];
                    //[weakSelf.yfSession openLog:YES];
                    weakSelf.logView.hidden = NO;
                }else{
                    btn.selected = NO;
                    icon.selected = NO;
                    [btn setTitle:@"日志/关" forState:UIControlStateNormal];
                    //[weakSelf.yfSession openLog:NO];
                    weakSelf.logView.hidden = YES;
                }
            }
            
        }];
        
        _settingView.cancel = ^(){
            weakSelf.settingView.hidden = YES;
            weakSelf.setBtn.hidden = NO;
        };
        
        _settingView.backgroundColor = [UIColor blackColor];
        _settingView.hidden = YES;
        [self.view addSubview:_settingView];
    }
    return _settingView;
}

- (YFBeautyView *)beautyView{
    if (!_beautyView) {
        _beautyView = [[YFBeautyView alloc] init];
        _beautyView.backgroundColor = [UIColor blackColor];
        _beautyView.hidden = YES;
        __weak typeof(self)weakSelf = self;
        _beautyView.callBack = ^(int i){
            [XXManager sharedManager].beautyLever = i * 0.2;
        };
        _beautyView.cancel = ^(){
            weakSelf.beautyView.hidden = YES;
            weakSelf.setBtn.hidden = NO;
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
                //标识没有ar动画
                [XXManager sharedManager].isOnlyBeauty = YES;
            }else{
                //加载ar动画
                [XXManager sharedManager].isOnlyBeauty = NO;
                NSString *path = [[NSBundle mainBundle] pathForResource:weakSelf.bundleArr[i-1] ofType:nil];
                [[XXManager sharedManager] reLoadItem:path];
            }
        };
        _arView.cancel = ^(){
            weakSelf.arView.hidden = YES;
            weakSelf.setBtn.hidden = NO;
        };
        _arView.hidden = YES;
        _arView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_arView];
    }
    return _arView;
}

- (NSArray *)bundleArr{
    if (!_bundleArr) {
        _bundleArr = @[@"PrincessCrown.bundle",@"BeagleDog.bundle",@"YellowEar.bundle",@"Deer.bundle",@"HappyRabbi.bundle",@"hartshorn.bundle",@"Mood.bundle",];
    }
    return _bundleArr;
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
            weakSelf.waterMark.hidden = YES;
            weakSelf.setBtn.hidden = NO;
        };
        _waterMark.hidden = YES;
        _waterMark.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_waterMark];
    }
    return _waterMark;
}

- (UIButton *)testBtn{
    if (!_testBtn) {
        _testBtn = [[UIButton alloc] init];
        [_testBtn addTarget:self action:@selector(didClickTest:) forControlEvents:UIControlEventTouchUpInside];
        [_testBtn setTitle:@"SwitchBeauty" forState:UIControlStateNormal];
        [self.view addSubview:_testBtn];
    }
    return _testBtn;
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

- (UIView *)sliderView{
    if (!_sliderView) {
        _sliderView = [[UIView alloc] init];
        _sliderView.backgroundColor = [UIColor clearColor];
        _sliderView.hidden = NO;
        [self.view addSubview:_sliderView];
    }
    return _sliderView;
}

- (UISlider *)RotateHue{
    if (!_RotateHue) {
        _RotateHue = [[UISlider alloc] initWithFrame:CGRectMake(100, 10, 200, 20)];
        
        _RotateHue.minimumValue = -360;
        _RotateHue.maximumValue = 360;
        _RotateHue.value = -0.88;
        _RotateHue.continuous = YES;
        [self.sliderView addSubview:_RotateHue];
        [_RotateHue addTarget:self action:@selector(sliderRotateHue:) forControlEvents:UIControlEventValueChanged];
    }
    return _RotateHue;
}

- (UISlider *)Saturation{
    if (!_Saturation) {
        _Saturation = [[UISlider alloc] initWithFrame:CGRectMake(100, 40, 200, 20)];
        _Saturation.minimumValue = 0;
        _Saturation.maximumValue = 2;
        _Saturation.value = 1;
        _Saturation.continuous = YES;
        [self.sliderView addSubview:_Saturation];
        [_Saturation addTarget:self action:@selector(sliderSaturation:) forControlEvents:UIControlEventValueChanged];
    }
    return _Saturation;
}

- (UISlider *)Brightness{
    if (!_Brightness) {
        _Brightness = [[UISlider alloc] initWithFrame:CGRectMake(100, 70, 200, 20)];
        _Brightness.minimumValue = 0;
        _Brightness.maximumValue = 2;
        _Brightness.value = 1;
        _Brightness.continuous = YES;
        [self.sliderView addSubview:_Brightness];
        [_Brightness addTarget:self action:@selector(sliderbrightness:) forControlEvents:UIControlEventValueChanged];
        
    }
    
    return _Brightness;
}

- (UISlider *)Exposureness{
    if (!_Exposureness) {
        _Exposureness = [[UISlider alloc] initWithFrame:CGRectMake(100, 100, 200, 20)];
        _Exposureness.minimumValue = 0;
        _Exposureness.maximumValue = 1;
        _Exposureness.value = 0.3;
        _Exposureness.continuous = YES;
        [self.sliderView addSubview:_Exposureness];
        [_Exposureness addTarget:self action:@selector(sliderExposureness:) forControlEvents:UIControlEventValueChanged];
    }
    return _Exposureness;
}

- (UISlider *)Temperatureness{
    if (!_Temperatureness) {
        _Temperatureness = [[UISlider alloc] initWithFrame:CGRectMake(100, 130, 200, 20)];
        _Temperatureness.minimumValue = 0;
        _Temperatureness.maximumValue = 10000;
        _Temperatureness.value = 5000;
        _Temperatureness.continuous = YES;
        [self.sliderView addSubview:_Temperatureness];
        [_Temperatureness addTarget:self action:@selector(sliderTemperatureness:) forControlEvents:UIControlEventValueChanged];
    }
    return _Temperatureness;
}

- (UISlider *)Blurness{
    if (!_Blurness) {
        _Blurness = [[UISlider alloc] initWithFrame:CGRectMake(100, 160, 200, 20)];
        _Blurness.minimumValue = 0;
        _Blurness.maximumValue = 8;
        _Blurness.value = 3.8;
        _Blurness.continuous = YES;
        [self.sliderView addSubview:_Blurness];
        [_Blurness addTarget:self action:@selector(sliderBlurness:) forControlEvents:UIControlEventValueChanged];
    }
    return _Blurness;
}

- (UISlider *)redLevel{
    if (!_redLevel) {
        _redLevel = [[UISlider alloc] initWithFrame:CGRectMake(100, 210, 200, 20)];
        _redLevel.minimumValue = 0;
        _redLevel.maximumValue = 1;
        _redLevel.value = 0.1;
        _redLevel.continuous = YES;
        [self.sliderView addSubview:_redLevel];
        [_redLevel addTarget:self action:@selector(sliderRedLevel:) forControlEvents:UIControlEventValueChanged];
    }
    return _redLevel;
}

- (UISlider *)BlurLevel{
    if (!_BlurLevel) {
        _BlurLevel = [[UISlider alloc] initWithFrame:CGRectMake(100, 240, 200, 20)];
        _BlurLevel.minimumValue = -1;
        _BlurLevel.maximumValue = 1;
        _BlurLevel.value = 0.1;
        _BlurLevel.continuous = YES;
        [self.sliderView addSubview:_BlurLevel];
        [_BlurLevel addTarget:self action:@selector(sliderBlurLevel:) forControlEvents:UIControlEventValueChanged];
    }
    return _BlurLevel;
}

- (UISlider *)globalSaturation{
    if (!_globalSaturation) {
        _globalSaturation = [[UISlider alloc] initWithFrame:CGRectMake(100, 270, 200, 20)];
        _globalSaturation.minimumValue = 0;
        _globalSaturation.maximumValue = 1;
        _globalSaturation.value = 0.3;
        _globalSaturation.continuous = YES;
        [self.sliderView addSubview:_globalSaturation];
        [_globalSaturation addTarget:self action:@selector(sliderGlobalSaturation:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _globalSaturation;
}

- (UISlider *)globalBrightNess{
    if (!_globalBrightNess) {
        _globalBrightNess = [[UISlider alloc] initWithFrame:CGRectMake(100, 300, 200, 20)];
        _globalBrightNess.minimumValue = -0.5;
        _globalBrightNess.maximumValue = 1;
        _globalBrightNess.value = 0;
        _globalBrightNess.continuous = YES;
        [self.sliderView addSubview:_globalBrightNess];
        [_globalBrightNess addTarget:self action:@selector(sliderGlobalBrightNess:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _globalBrightNess;
}

- (UIButton *)switchBtn{
    if (!_switchBtn) {
        _switchBtn = [[UIButton alloc] init];
        [_switchBtn setTitle:@"SwitchView" forState:UIControlStateNormal];
        [_switchBtn addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_switchBtn];
    }
    return _switchBtn;
}

- (UIView *)filterView{
    if (!_filterView) {
        _filterView = [[UIView alloc] init];
        _filterView.backgroundColor = [UIColor clearColor];
        _filterView.hidden = YES;
        [self.view addSubview:_filterView];
    }
    return _filterView;
}

- (UIButton *)cameraFilter{
    if (!_cameraFilter) {
        _cameraFilter = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 120, 40)];
        [_cameraFilter setTitle:@"CameraFilter" forState:UIControlStateNormal];
        [_cameraFilter addTarget:self action:@selector(switchYFCameraFilter:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraFilter;
}

- (UIButton *)INSBtn{
    if (!_INSBtn) {
        _INSBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 80, 120, 40)];
        [_INSBtn setTitle:@"StyleFilter" forState:UIControlStateNormal];
        [_INSBtn addTarget:self action:@selector(switchStyleFilter:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _INSBtn;
}

- (void)switchYFCameraFilter:(UIButton *)sender{
    [self.yfSession.videoCamera setupFilter:(YfSessionCameraFilter)self.index];
    self.index++;
    if (self.index == 9) {
        self.index = 0;
    }
}

- (void)switchStyleFilter:(UIButton *)sender{
    [self.yfSession.videoCamera switchFilter:(YFINSTCameraFilterType)self.index2];
    self.index2++;
    if (self.index2 == 18) {
        self.index2 = 0;
    }
}

- (UIButton *)testBtn2{
    if (!_testBtn2) {
        _testBtn2 = [[UIButton alloc] init];
        [_testBtn2 setTitle:@"on/off" forState:UIControlStateNormal];
        [_testBtn2 addTarget:self action:@selector(onOffBeauty:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_testBtn2];
    }
    return _testBtn2;
}

- (UIView *)logView{
    if (!_logView) {
        _logView = [[UIView alloc] init];
        _logView.backgroundColor = [UIColor grayColor];
        _logView.alpha = 0.5;
        _logView.hidden = YES;
        [self.view addSubview:_logView];
    }
    return _logView;
}

- (UILabel *)SRspeedLab{
    if (!_SRspeedLab) {
        _SRspeedLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width, 20)];
        
        [self.logView addSubview:_SRspeedLab];
    }
    return _SRspeedLab;
}

- (UILabel *)runInfoLab{
    if (!_runInfoLab) {
        _runInfoLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, self.view.bounds.size.width, 270)];
        _runInfoLab.numberOfLines = 0;
        [self.logView addSubview:_runInfoLab];
    }
    return _runInfoLab;
}

@end
