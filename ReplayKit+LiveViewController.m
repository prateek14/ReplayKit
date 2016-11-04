#import "ReplayKit+LiveViewController.h"
#import "FloatingWindow.h"

@interface ReplayKitLiveViewController()

@property (nonatomic,strong) FloatingWindow *floatWindow;

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
    _floatWindow = [[FloatingWindow alloc]initWithFrame:CGRectMake(0, 200, 50, 50) mainImageName:@"zzz" imagesAndTitle:@{@"ddd":@"用户中心",@"eee":@"退出登录",@"fff":@"客服中心"} bgcolor:[UIColor lightGrayColor] animationColor:[UIColor purpleColor]];
    
    _floatWindow.clickBolcks = ^(FloatingButtonIndex btnIndex){
        switch(btnIndex)
        {
            case FloatingButton_Live:
            {
                [self startRecorder];
                break;
            }
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
    _floatWindow.rootViewController = self;
    [_floatWindow makeKeyAndVisible];
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
