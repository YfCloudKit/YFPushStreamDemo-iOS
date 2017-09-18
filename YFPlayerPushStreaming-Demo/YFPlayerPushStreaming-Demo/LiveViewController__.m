#import "LiveViewController.h"
#import <YFMediaPlayerPushStreaming/YFMediaPlayerPushStreaming.h>
#import "AFNetworking.h"
#import "ControlView.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface LiveViewController ()<YfSessionDelegate,ControlViewDelegate>

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


@property (nonatomic,strong) CTCallCenter *callCenter;


@end

@implementation LiveViewController
{
    ControlView *controlView;
    
    NSMutableArray *registeredNotifications;
    
    BOOL isPushed;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //http://v3.cztv.com/cztv/vod/2016/09/22/140c5c605151436fa7b9488b2008a1d3/h264_450k_mp4.mp4_playlist.m3u8
    
    isPushed = NO;
    
    registeredNotifications = [[NSMutableArray alloc] init];
    
    self.retryPushStreamCount = 5;
    
    self.reachabilityMannger = [AFNetworkReachabilityManager sharedManager];
    [self.reachabilityMannger startMonitoring];
    [self networkReachabilityStatusChange];
    
    [self setupYfSession];
    
    
    controlView = [[ControlView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    controlView.delegateSession = _yfSession;
    controlView.pushUrl = self.pushUrlString;
    controlView.delegate = self;
    [self.view insertSubview:controlView atIndex:1];

    //[self registerApplicationObservers];

    [self detectCall];
}

- (void)detectCall{
    
    __weak LiveViewController *weakself = self;
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall *call){
        
        if (call.callState == CTCallStateDisconnected) {
            NSLog(@"挂掉电话了");
            if (weakself.yfSession) {
                [weakself.yfSession startRtmpSessionWithRtmpURL:weakself.pushUrlString];
            }
            
        }else if (call.callState == CTCallStateConnected){
            NSLog(@"接电话了");
        }else if (call.callState == CTCallStateIncoming){
            NSLog(@"来电话了");
            if (weakself.yfSession) {
                [weakself.yfSession endRtmpSession];
            }
        }
        else if (call.callState == CTCallStateDialing){
            
            NSLog(@"call is dialling");
        }
    };
}

- (void)onBackBtn{

    [_yfSession shutdownRtmpSession];
    [_yfSession releaseRtmpSession];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark app state changed

- (void)registerApplicationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [registeredNotifications addObject:UIApplicationWillEnterForegroundNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [registeredNotifications addObject:UIApplicationDidBecomeActiveNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [registeredNotifications addObject:UIApplicationWillResignActiveNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [registeredNotifications addObject:UIApplicationDidEnterBackgroundNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    [registeredNotifications addObject:UIApplicationWillTerminateNotification];
}

- (void)unregisterApplicationObservers
{
    for (NSString *name in registeredNotifications) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:name
                                                      object:nil];
    }
}

- (void)applicationWillEnterForeground
{

    
}

- (void)applicationDidBecomeActive
{

    
}

- (void)applicationWillResignActive
{
    NSLog(@"%s",__func__);
    

}

- (void)applicationDidEnterBackground
{
    NSLog(@"%s",__func__);
    
    if (_yfSession) {
        [_yfSession endRtmpSession];
    }
    
}

- (void)applicationWillTerminate
{
    NSLog(@"%s",__func__);
}



- (void)setupYfSession{
    if (!_yfSession) {
        _yfSession = [[YfSession alloc] initWithVideoSize:CGSizeMake(360, 640) frameRate:24 bitrate:640000 bufferTime:3 isBeautifulOpen:YES];
        if (_yfSession) {
            [self.view insertSubview:_yfSession.previewView atIndex:0];
            _yfSession.delegate = self;
            _yfSession.IsAudioOpen = YES;
        }
    }
}

#pragma mark ------取得当前数据--------

- (void)yfPushStreamingCameraSource:(CVPixelBufferRef)pixelbuffer size:(size_t)pixelbufferSize{
    
    // do anything you want
    //do not release pixelbuffer
    
    
    
    
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

            [controlView.connectedBtn setTitle:@"正在连接流服务器..." forState:UIControlStateNormal];
            NSLog(@"正在连接流服务器...");
        }
            break;
        case YfSessionStateStarted: {
            _rtmpSessionState = YfSessionStateStarted;

            NSLog(@"连接成功，推流开始");
             [controlView.connectedBtn setTitle:@"连接成功，推流开始" forState:UIControlStateNormal];
            
            self.retryPushStreamCount = 5;
        }
            break;
        case YfSessionStateEnded: {
            _rtmpSessionState = YfSessionStateEnded;
            [controlView.connectedBtn setTitle:@"推流结束" forState:UIControlStateNormal];

        }
            break;
        case YfSessionStateError: {
            _rtmpSessionState = YfSessionStateError;
             [controlView.connectedBtn setTitle:@"连接成功，推流开始" forState:UIControlStateNormal];
            NSLog(@"连接流服务器出错");
            
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

- (void)shutDownButtonClicked:(id)sender{

    if (_yfSession) {
        [_yfSession shutdownRtmpSession];
        NSLog(@"%s endRtmpSession",__FUNCTION__);
    }
}




-(void)dealloc{
    //[self unregisterApplicationObservers];
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
