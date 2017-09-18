#import "LiveViewController.h"
#import <YFMediaPlayerPushStreaming/YFMediaPlayerPushStreaming.h>
#import "AFNetworking.h"

@interface LiveViewController ()<YfSessionDelegate>

@property(nonatomic,strong) YfSession *yfSession;

/**
 *  网络判断管理类
 */
@property(nonatomic,strong) AFNetworkReachabilityManager *reachabilityMannger;

/**
 *  云帆推流状态
 */
@property(nonatomic,assign) YfSessionState rtmpSessionState;

/**
 *  是否手动点击关闭推流
 */
@property(nonatomic,assign) BOOL isManualCloseLive;

/**
 *  重推流的最大次数
 */
@property (nonatomic, assign) NSInteger retryPushStreamCount;

@property (nonatomic,strong) UILabel* yfStatusLabel;

@property (nonatomic,strong) UIButton* closeButton;

@property (nonatomic,strong)UIButton *shutDownButton;

@property (nonatomic,strong) UIButton* startPushStreamButton;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.retryPushStreamCount = 5;
    
    self.reachabilityMannger = [AFNetworkReachabilityManager sharedManager];
    [self.reachabilityMannger startMonitoring];
    [self networkReachabilityStatusChange];
    
    [self setupYfSession];
    
    [self.startPushStreamButton addTarget:self action:@selector(startStreamClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.shutDownButton addTarget:self action:@selector(shutDownButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIPinchGestureRecognizer *ping = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    [self.view addGestureRecognizer:ping];
    
    [self addObserver];
    
}


- (void)zoom:(UIPinchGestureRecognizer*)ping{
    
     //  NSLog(@"sender.scale == %d",ping.scale);
    if (self.yfSession) {
        [self.yfSession SetVideoZoom:ping.scale];
    }
    
}

- (void)addObserver{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)gotoActive{
    if (_yfSession) {
       [self retryPushStream];
    }
}

- (void)gotoBack{
    
    [self shutDownButtonClicked:nil];
}

- (UIButton*)shutDownButton{
    if (!_shutDownButton) {
        _shutDownButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 150, 150, 40)];
        [_shutDownButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_shutDownButton setTitle:@"shutDown" forState:UIControlStateNormal];
        [self.view addSubview:_shutDownButton];
    }
    return _shutDownButton;
}

- (UILabel*)yfStatusLabel{
    if (!_yfStatusLabel) {
        _yfStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 200, 25)];
        [self.view addSubview:_yfStatusLabel];
    }
    return _yfStatusLabel;
}

- (UIButton*)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 100, 150, 40)];
        [_closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_closeButton setTitle:@"close" forState:UIControlStateNormal];
        [self.view addSubview:_closeButton];
    }
    return _closeButton;
}

- (UIButton*)startPushStreamButton{
    if (!_startPushStreamButton) {
        _startPushStreamButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 150, 150, 40)];
        [_startPushStreamButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_startPushStreamButton setTitle:@"start push stream" forState:UIControlStateNormal];
        
        [self.view addSubview:_startPushStreamButton];
    }
    return _startPushStreamButton;
}

- (void)setupYfSession{
    if (!_yfSession) {
        _yfSession = [[YfSession alloc] initWithVideoSize:CGSizeMake(360, 640) frameRate:24 bitrate:800000 bufferTime:3 isBeautifulOpen:YES];
        if (_yfSession) {
            [self.view insertSubview:_yfSession.previewView atIndex:0];
            _yfSession.delegate = self;
            _yfSession.IsAudioOpen = YES;
        }
    }
}

-(void)startStreamClicked:(id)sender{
    if ((self.reachabilityMannger.isReachable)) {
        if(self.yfSession){
            [self.yfSession startRtmpSessionWithRtmpURL:self.pushUrlString];
        }
    }else{
        NSLog(NSLocalizedString(@"Network error. Please check your network connection.", nil));
    }
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
            case AFNetworkReachabilityStatusReachableViaWWAN:
                result = @"WAN";
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                result = @"WIFI";
                break;
            default:
                break;
        }
        NSLog(@"--%s current network status:%@",__FUNCTION__,result);
        [weakSelf restorePushStream:status];
    }];
}

/**
 *  恢复推流
 *
 *  @param status 网络状态
 */
- (void)restorePushStream:(AFNetworkReachabilityStatus)status{
    if (status == AFNetworkReachabilityStatusNotReachable) {
        NSLog(@"Network error. Please check your network connection.");
        //TODO 通知云帆sdk,当前网络无法连接
        if(self.yfSession && self.pushUrlString){
            [self.yfSession ShutErrorRtmpSession];//立即收到推流错误的回调
            NSLog(@"%s ShutErrorRtmpSession",__FUNCTION__);
        }
    }else{
        NSLog(@"%s rtmpSessionState=%zd",__FUNCTION__ , _rtmpSessionState);
        //上一次推流错误，网络恢复的时候 重新推流
        if (self.pushUrlString && self.yfSession && _rtmpSessionState == YfSessionStateError) {
            NSLog(@"%s 重新推流 startRtmpSessionWithRtmpURL",__FUNCTION__);
            [self.yfSession startRtmpSessionWithRtmpURL:self.pushUrlString];
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
            if (self.yfSession && self.pushUrlString) {
                [self.yfSession startRtmpSessionWithRtmpURL:self.pushUrlString];
            }
        });
    }
}

#pragma mark - 云帆推流连接回调通知

- (void)connectionStatusChanged:(YfSessionState) state{
    switch(state) {
        case YfSessionStateNone: {
            _rtmpSessionState = YfSessionStateNone;
#ifdef DEBUG
            self.yfStatusLabel.text = @"YfSessionStateNone";
#endif
            NSLog(@"YfSessionStateNone");
        }
            break;
            
        case YfSessionStatePreviewStarted: {
            _rtmpSessionState = YfSessionStatePreviewStarted;
            NSLog(@"初始化完成");
#ifdef DEBUG
            self.yfStatusLabel.hidden = NO;
            self.yfStatusLabel.text = @"初始化完成";
#endif
        }
            break;
        case YfSessionStateStarting: {
            _rtmpSessionState = YfSessionStateStarting;
#ifdef DEBUG
            self.yfStatusLabel.text = @"正在连接流服务器...";
#endif
            NSLog(@"正在连接流服务器...");
        }
            break;
        case YfSessionStateStarted: {
            _rtmpSessionState = YfSessionStateStarted;
#ifdef DEBUG
            self.yfStatusLabel.text = @"连接成功，推流开始";
#endif
            NSLog(@"连接成功，推流开始");
            
            self.retryPushStreamCount = 5;
        }
            break;
        case YfSessionStateEnded: {
            _rtmpSessionState = YfSessionStateEnded;
#ifdef DEBUG
            self.yfStatusLabel.text = @"推流结束";
#endif

        }
            break;
        case YfSessionStateError: {
            _rtmpSessionState = YfSessionStateError;
            NSLog(@"连接流服务器出错");
#ifdef DEBUG
            self.yfStatusLabel.text = @"连接流服务器出错";
#endif
            
            if (self.isManualCloseLive) {
                if (_yfSession) {
                    [_yfSession releaseRtmpSession];//停止rtmp session，释放资源，不会触发rtmp session结束通知
                    NSLog(@"%s releaseRtmpSession",__FUNCTION__);
                }
            }else{
                if (self.yfSession && self.pushUrlString) {
                    [self.yfSession shutdownRtmpSession]; //释放rtmp session相关资源
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

-(void)closeButtonClicked:(id)sender{
//    if (_yfSession) {
//        if (_rtmpSessionState == YfSessionStateError) {
//            [_yfSession releaseRtmpSession];//出现推流错误，直接释放资源
//            NSLog(@"%s releaseRtmpSession",__FUNCTION__);
//        }else{
//            [_yfSession endRtmpSession]; //停止rtmp session，不释放资源，会触发rtmp session结束通知
//            NSLog(@"%s endRtmpSession",__FUNCTION__);
//        }
//    }
//
    [_yfSession shutdownRtmpSession];
     [_yfSession releaseRtmpSession];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shutDownButtonClicked:(id)sender{
    
    if (_yfSession) {
        [_yfSession shutdownRtmpSession];
        NSLog(@"%s endRtmpSession",__FUNCTION__);
    }
    
}

-(void)dealloc{
    [self.reachabilityMannger stopMonitoring];
    
    [_yfSession releaseRtmpSession];
    NSLog(@"%s releaseRtmpSession",__FUNCTION__);
    [_yfSession.previewView removeFromSuperview];
    _yfSession = nil;
    
    NSLog(@"%s",__FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
