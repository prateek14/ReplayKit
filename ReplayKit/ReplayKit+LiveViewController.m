#import "ReplayKit+LiveViewController.h"
#import "ReplayKitLiveViewModel.h"
#import "ReplayKitLiveView.h"
#import "WebKit/WebKit.h"
#import "ReplayKitLiveView.h"
#import "UnityAppController.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ReplayKitLiveViewController()

@property (strong, nonatomic) ReplayKitLiveViewModel *liveVM;
@property (nonatomic) IBOutlet ReplayKitLiveView *liveView;
@property (nonatomic, weak) UIView *cameraPreview;

@property (nonatomic, copy) NSURL *chatURL;
@property (nonatomic, strong) WKWebView *chatView;

@end

@implementation ReplayKitLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showFloatWindow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showFloatWindow{
    self.liveVM = [[ReplayKitLiveViewModel alloc] initWithViewController:self];
    [self.liveVM addObserver:self forKeyPath:@"living" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    self.liveView = [[ReplayKitLiveView alloc]initWithFrame:CGRectMake(0, kScreenWidth / 2, 70, 70) bgcolor:[UIColor clearColor] animationColor:[UIColor purpleColor]];
    [_liveView setupVMObserver:_liveVM];
    _liveVM.microphoneEnabled = YES;
    _liveVM.cameraEnabled = YES;
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
    _liveView.rootViewController = self;
    [_liveView makeKeyAndVisible];

}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"living"])
    {
        if (_liveVM.isLiving) {
            UIView* cameraView = [_liveVM cameraPreview];
            if (self.cameraPreview != cameraView) {
                if (self.cameraPreview.superview) {
                    [self.cameraPreview removeFromSuperview];
                }
                NSLog(@"Camera view frame:%@", NSStringFromCGRect(cameraView.frame));
                self.cameraPreview = cameraView;
                if(cameraView)
                {
                    // If the camera is enabled, create the camera preview and add it to the game's UIView
                    cameraView.frame = CGRectMake(0, 0, 200, 200);
                    [self.view addSubview:cameraView];
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
            }
        }
        else {
            self.chatURL = nil;
            [self didCameraViewTapped:nil];
            [self.cameraPreview removeFromSuperview];
            self.cameraPreview = nil;
        }
    }
}
- (void)didCameraViewPanned:(UIPanGestureRecognizer*)sender
{
    // Move the Camera view around by dragging
    CGPoint translation = [sender translationInView:self.view];
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
    
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
}
- (void)didCameraViewTapped:(UITapGestureRecognizer*)sender
{
    // Load the chat view if we have a chat URL
    if(!self.chatView && self.chatURL)
    {
        CGSize parentSize = self.view.frame.size;
        CGFloat ypos = CGRectGetMaxY(self.cameraPreview.frame);
        self.chatView = [[WKWebView alloc] initWithFrame:CGRectMake(self.cameraPreview.frame.origin.x,
                                                                    ypos,
                                                                    300,
                                                                    parentSize.height - ypos)];
        NSURLRequest* request = [NSURLRequest requestWithURL:self.chatURL];
        [self.chatView loadRequest:request];
        [self.chatView setBackgroundColor:[UIColor grayColor]];
        [self.chatView setOpaque:NO];
        [self.view addSubview:self.chatView];
    }
    else if(self.chatView)
    {
        [self.chatView removeFromSuperview];
        self.chatView = nil;
    }
}
#pragma mark - ios9 shared operation
- (void)startRecorder
{
    RPScreenRecorder *recorder = [RPScreenRecorder sharedRecorder];
    if (!recorder.available) {
        NSLog(@"recorder is not available");
        return;
    }
    if (recorder.recording) {
        NSLog(@"it is recording");
        return;
    }
    [recorder startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"start recorder error - %@",error);
        }
        //[self.startBtn setTitle:@"Recording" forState:UIControlStateNormal];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
