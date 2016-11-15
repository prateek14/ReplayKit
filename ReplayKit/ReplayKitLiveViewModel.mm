#import "ReplayKitLiveViewModel.h"
#import "WebKit/WebKit.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
//#define CheckStartTimeout 5

@interface ReplayKitLiveViewModel(){
}
@property (weak, nonatomic) RPBroadcastController *broadcastController;
@property (strong, nonatomic) RPBroadcastController *strongBC;  // 暂停的时候强引用
//@property (nonatomic, weak) UIView *cameraPreview;
@property (nonatomic, strong) WKWebView *chatView;
@property (copy, nonatomic) NSURL *chatURL;
@property (assign, nonatomic, getter=isPaused) BOOL paused;
@property (assign, nonatomic, getter=isLiving) BOOL living;

//@property (weak, nonatomic) NSTimer *startCheckTimer;
@end


@implementation ReplayKitLiveViewModel

static ReplayKitLiveViewModel* _instance = nil;
+ (instancetype)Instance
{
    if (_instance == nil)
    {
        _instance = [[ReplayKitLiveViewModel alloc] initWithViewController:nil];
    }
    return _instance;
}

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        if(nil == vc)
        {
            _ownerViewController = [[UnityGetGLView() window] rootViewController];
            //_ownerViewController = [[ReplayKitLiveViewController alloc] init];
            //_ownerViewController.view.window.rootViewController = [[UnityGetGLView() window] rootViewController];
            //[[[UnityGetGLView() window] rootViewController] addChildViewController:_ownerViewController];
            //[UnityGetGLView() addSubview:_ownerViewController.view];
        }
        else
        {
            _ownerViewController = vc;
        }
        if(nil != _ownerViewController)
        {
            //_ownerViewController.automaticallyAdjustsScrollViewInsets = NO;
            [self addObserver:self forKeyPath:@"living" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            [self showFloatWindow];
            self.microphoneEnabled = YES;
            self.cameraEnabled = YES;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkLivingStatus)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkNeedResumeLiving)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkLivingStatus)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showFloatWindow{
    self.liveView = [[ReplayKitLiveView alloc]initWithFrame:CGRectMake(kScreenWidth * 0.25, kScreenHeight * 0.6, 60, 60) bgcolor:[UIColor clearColor] animationColor:[UIColor purpleColor]];
    _liveView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_ownerViewController.view addSubview:self.liveView];
    [_liveView setupVMObserver:self];
    _liveView.clickBolcks = ^(FloatingButtonIndex btnIndex){
        switch(btnIndex)
        {
            case FloatingButton_Live:
                break;
            case FloatingButton_Pause:
                break;
            case FloatingButton_Micphone:
                break;
            case FloatingButton_Webcam:
                break;
            case FloatingButton_Stop:
                break;
        }
    };
    
}
- (void)enterLive
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
        return;
    UIView* cameraView = [RPScreenRecorder sharedRecorder].cameraPreviewView;
    //            if (self.cameraPreview != cameraView) {
    //                if (self.cameraPreview.superview) {
    //                    [self.cameraPreview removeFromSuperview];
    //                }
    //                NSLog(@"Camera view frame:%@", NSStringFromCGRect(cameraView.frame));
    //                self.cameraPreview = cameraView;
    if(cameraView)
    {
        if (cameraView.superview) {
            [cameraView removeFromSuperview];
        }
        // If the camera is enabled, create the camera preview and add it to the game's UIView
        cameraView.frame = CGRectMake(0, 0, 200, 200);
        [self.ownerViewController.view addSubview:cameraView];
        {
            // Add a gesture recognizer so the user can drag the camera around the screen
            UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didCameraViewPanned:)];
            pgr.minimumNumberOfTouches = 1;
            pgr.maximumNumberOfTouches = 1;
            [cameraView addGestureRecognizer:pgr];
        }
        {
            UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCameraViewTapped:)];
            [cameraView addGestureRecognizer:tgr];
        }
    }
    //            }
}
- (void)exitLive
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
    {
        self.chatURL = nil;
        return;
    }
    UIView* cameraView = [RPScreenRecorder sharedRecorder].cameraPreviewView;
    self.chatURL = nil;
    [self didCameraViewTapped:nil];
    if(cameraView)
        [cameraView removeFromSuperview];
    //[self.cameraPreview removeFromSuperview];
    //self.cameraPreview = nil;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"living"])
    {
        if ([NSThread isMainThread])
        {
            if (self.isLiving)
            {
                [self enterLive];
            }
            else
            {
                [self exitLive];
            }
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                //Update UI in UI thread here
                if (self.isLiving)
                {
                    [self enterLive];
                }
                else
                {
                    [self exitLive];
                }
                
            });
        }
    }
}
- (void)didCameraViewPanned:(UIPanGestureRecognizer*)sender
{
    // Move the Camera view around by dragging
    CGPoint translation = [sender translationInView:self.ownerViewController.view];
    {
        CGRect recognizerFrame = sender.view.frame;
        recognizerFrame.origin.x += translation.x;
        recognizerFrame.origin.y += translation.y;
        
        sender.view.frame = recognizerFrame;
    }
    if(self.chatView)
    {
        CGRect recognizerFrame = self.chatView.frame;
        recognizerFrame.origin.x += translation.x;
        recognizerFrame.origin.y += translation.y;
        
        self.chatView.frame = recognizerFrame;
    }
    
    [sender setTranslation:CGPointMake(0, 0) inView:self.ownerViewController.view];
}
- (void)didCameraViewTapped:(UITapGestureRecognizer*)sender
{
    // Load the chat view if we have a chat URL
    UIView* cameraView = [RPScreenRecorder sharedRecorder].cameraPreviewView;
    if(!self.chatView && self.chatURL && cameraView)
    {
        CGSize parentSize = self.ownerViewController.view.frame.size;
        CGFloat ypos = CGRectGetMaxY(cameraView.frame);
        self.chatView = [[WKWebView alloc] initWithFrame:CGRectMake(cameraView.frame.origin.x,
                                                                    ypos,
                                                                    300,
                                                                    parentSize.height - ypos)];
        NSURLRequest* request = [NSURLRequest requestWithURL:self.chatURL];
        [self.chatView loadRequest:request];
        [self.chatView setBackgroundColor:[UIColor grayColor]];
        [self.chatView setOpaque:NO];
        [self.ownerViewController.view addSubview:self.chatView];
    }
    else if(self.chatView)
    {
        [self.chatView removeFromSuperview];
        self.chatView = nil;
    }
}

- (void)setCameraEnabled:(BOOL)enable {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
        return;
    if (enable) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self willChangeValueForKey:@"cameraEnabled"];
            if (granted) {
                [RPScreenRecorder sharedRecorder].cameraEnabled = YES;
            }
            else {
                NSLog(@"User not allow camera access");
                [RPScreenRecorder sharedRecorder].cameraEnabled = NO;
            }
            [self didChangeValueForKey:@"cameraEnabled"];
        }];
    }
    else {
        [self willChangeValueForKey:@"cameraEnabled"];
        [RPScreenRecorder sharedRecorder].cameraEnabled = NO;
        [self didChangeValueForKey:@"cameraEnabled"];
    }
}

- (BOOL)isCameraEnabled {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
        return false;
    return [RPScreenRecorder sharedRecorder].isCameraEnabled;
}

- (BOOL)isMicrophoneEnabled {
    return [RPScreenRecorder sharedRecorder].isMicrophoneEnabled;
}

- (void)setMicrophoneEnabled:(BOOL)enable {
    if (enable) {
        [[AVAudioSession sharedInstance] requestRecordPermission: ^(BOOL granted){
            [self willChangeValueForKey:@"microphoneEnabled"];
            if (granted) {
                [RPScreenRecorder sharedRecorder].microphoneEnabled = YES;
            }
            else {
                NSLog(@"User not allow microphone access");
                [RPScreenRecorder sharedRecorder].microphoneEnabled = NO;
            }
            [self didChangeValueForKey:@"microphoneEnabled"];
        }];
    }
    else {
        [self willChangeValueForKey:@"microphoneEnabled"];
        [RPScreenRecorder sharedRecorder].microphoneEnabled = NO;
        [self didChangeValueForKey:@"microphoneEnabled"];
    }
}

- (void)start {
    if (self.broadcastController.isBroadcasting) {
        NSLog(@"It is broadcasting...");
        return ;
    }
    NSAssert(_ownerViewController, @"没有控制器玩不了...");
    //@WeakObj(self)
    [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error)
    {
        //@StrongObj(self);
        if (!error) {
            broadcastActivityViewController.delegate = self;
            broadcastActivityViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self.ownerViewController presentViewController:broadcastActivityViewController animated:YES completion:nil];
        }
        else {
            [self onStopped:error];
        }
    }];
}

- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(nullable RPBroadcastController *)broadcastController error:(nullable NSError *)error
{
    //@WeakObj(self)
    [broadcastActivityViewController dismissViewControllerAnimated:YES completion:^{
        //@StrongObj(self)
        if (!error) {
            // 如果之前竟然还有一个RPBroadcastController, 先解除上一个对象的代理
            if (self.broadcastController) {
                NSLog(@"There still a RPBroadcastController???");
                self.broadcastController.delegate = nil;
            }
            self.broadcastController = broadcastController;
            [self doStartBroadcast];
        }
        else {
            [self onStopped:error];
        }
    }];
}

- (void)doStartBroadcast {
    NSLog(@"Start broadcast:%@", self.broadcastController);
    self.broadcastController.delegate = self;
    //@WeakObj(self)
    [self.broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
        //@StrongObj(self);
        if (!error) {
            [self onStarted];
        }
        else {
            [self onStopped:error];
        }
        //[self releaseCheckStartTimer];
    }];
    //[self createCheckStartTimer];
    //[self start];
}

//- (void)createCheckStartTimer {
//    //@WeakObj(self);
//    _startCheckTimer = [NSTimer scheduledTimerWithTimeInterval:CheckStartTimeout repeats:NO block:^(NSTimer * _Nonnull timer) {
//        //@StrongObj(self);
//        // auto retry
//        NSLog(@"Start timeout, auto retry...");
//        [self start];
//    }];
//}

//- (void)releaseCheckStartTimer {
//    if (_startCheckTimer) {
//        [_startCheckTimer invalidate];
//        _startCheckTimer = nil;
//    }
//}

- (BOOL)isLiving {
    return self.broadcastController.isBroadcasting;
}

- (NSURL *)broadcastURL {
    return self.broadcastController.broadcastURL;
}

- (void)broadcastController:(RPBroadcastController *)broadcastController didFinishWithError:(NSError * __nullable)error{
    NSLog(@"broadcastController:didFinishWithError:%@", error);
    [self onStopped:error];
}

- (void)checkLivingStatus {
    BOOL isLiving = self.broadcastController.isBroadcasting;
    if (isLiving != self.living) {
        self.living = isLiving;
    }
    BOOL isPaused = self.broadcastController.paused;
    if (isPaused != self.paused) {
        self.paused = isPaused;
    }
}
- (void) checkNeedResumeLiving {
    BOOL isLiving = self.broadcastController.isBroadcasting;
    if (isLiving && self.isPaused) {
        UIAlertController *ask = [[UIAlertController alloc] init];
        ask.title = @"恢复直播";
        ask.message = @"直播已经暂停了，是否立刻恢复直播？";
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"恢复" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self resume];
        }];
        UIAlertAction *no = [UIAlertAction actionWithTitle:@"不恢复" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [ask dismissViewControllerAnimated:YES completion:nil];
        }];
        [ask addAction:yes];
        [ask addAction:no];
        [self.ownerViewController presentViewController:ask animated:YES completion:nil];
    }
}
// 一些私有协议
// updateServiceInfo的格式是一个固定的字典
// 通过RPInfo_EventKey得到通知的类型
// 通过RPInfo_EventValue得到通知类型对应的值
#define RPInfo_EventKey     @"InfoEventKey"
#define RPInfo_EventValue   @"InfoEventValue"

// RPInfo_EventKey如下:
// 聊天URL, 对应的值是一个URL字符串(不是NSURL)
#define RPInfo_EventChatURL     @"InfoEventChatURL"
// 直播结束, 对应的值是结束原因
#define RPInfo_EventLiveStop    @"InfoEventLiveStopped"
// 直播错误, 对应的值是一个错误信息的字符串
#define RPInfo_EventLiveError   @"InfoEventLiveError"
// 统计数据, 对应的值是一个字典, 字典内容就不再一一介绍了
#define RPInfo_EventLiveStat   @"InfoEventLiveStat"

// Watch for service info from broadcast service
- (void)broadcastController:(RPBroadcastController *)broadcastController
       didUpdateServiceInfo:(NSDictionary <NSString *, NSObject <NSCoding> *> *)serviceInfo
{
    NSLog(@"didUpdateServiceInfo: %@", serviceInfo);
    NSString *event = (NSString *)serviceInfo[RPInfo_EventKey];
    if ([event isEqualToString:RPInfo_EventChatURL]) {
        NSString *chatUrl = (NSString *)serviceInfo[RPInfo_EventValue];
        self.chatURL = [NSURL URLWithString:chatUrl];
    }
    else if ([event isEqualToString:RPInfo_EventLiveError]) {
        // ERROR handler
        NSLog(@"broadcasting service report error");
        [self stop];
    }
    else if ([event isEqualToString:RPInfo_EventLiveStop]) {
        // STOPPED handler
        NSLog(@"broadcasting service report stopped");
        [self stop];
    }
}

- (void)onStarted {
    NSLog(@"Live started:%@", self.broadcastController.broadcastURL);
    
    if ([self.delegate respondsToSelector:@selector(rpliveStarted)]) {
        [self.delegate rpliveStarted];
    }
    self.living = YES;
}

- (void)onStopped:(NSError *)error {
    if (error) {
        NSLog(@"Live stopped with error:%@", error);
    }
    else {
        NSLog(@"Live stopped normally");
    }
    
    if ([self.delegate respondsToSelector:@selector(rpliveStoppedWithError:)]) {
        [self.delegate rpliveStoppedWithError:error];
    }
    self.living = NO;
}

- (void)pause {
    if (!self.broadcastController.isBroadcasting) {
        NSLog(@"Not living, how pause???");
        return ;
    }
    
    if (self.broadcastController.paused) {
        NSLog(@"Already paused!!!");
        return ;
    }
    // 强引用, 防止对象在paused之后被释放
    self.strongBC = self.broadcastController;
    
    [self.broadcastController pauseBroadcast];
    self.paused = self.broadcastController.paused;
}

-(void)setPaused:(BOOL)paused {
    _paused = paused;
    
    if ([self.delegate respondsToSelector:@selector(rplivePaused)]) {
        [self.delegate rplivePaused];
    }
}

- (void)resume {
    if (!self.broadcastController.isBroadcasting) {
        NSLog(@"Not living, how resume???");
        return ;
    }
    if (!self.broadcastController.paused) {
        NSLog(@"Not paused!!!");
        return ;
    }
    // 始终使用弱引用的对象来进行操作, strongBC只用来保持对象的生命周期.
    [self.broadcastController resumeBroadcast];
    
    self.strongBC = nil;
    
    self.paused = self.broadcastController.paused;
}

- (void)stop {
    if (!self.broadcastController.isBroadcasting) {
        NSLog(@"Not broadcasting, how stop???");
        return;
    }
    
    [self.broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
        if (!error) {
            // Normal stop
            [self onStopped:nil];
        }
        else {
            NSLog(@"finishBroadcastWithHandler error:%@", error);
            [self onStopped:error];
        }
        self.broadcastController = nil;
    }];
}

@end


extern "C" {
    bool replaykit_isLiveAvailable()
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
            return true;
        return false;
    }
    void replaykit_startLiveBroadcast()
    {
        [[[ReplayKitLiveViewModel Instance] liveView] showWindow];
    }
    void replaykit_stopLiveBroadcast()
    {
        [[[ReplayKitLiveViewModel Instance] liveView] dissmissWindow];
    }
}
