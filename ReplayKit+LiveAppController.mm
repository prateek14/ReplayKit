#import <UIKit/UIKit.h>
#import "UnityAppController.h"
#import "UI/UnityView.h"
#import "UI/UnityViewControllerBase.h"
#import "ReplayKit+LiveViewController.h"
#import "ScreenRecorder.h"

@interface ReplayKitLiveAppController : UnityAppController

@end

@implementation ReplayKitLiveAppController

- (void)willStartWithViewController:(UIViewController*)controller {
    // 新建自定义视图控制器。
    ReplayKitLiveViewController *floatViewController = [[ReplayKitLiveViewController alloc] init];
    
    // 把Unity的内容视图作为子视图放到我们自定义的视图里面。
    //[viewController.view addSubview:_unityView];
    //[_unityView setFrame:CGRectMake(0, 0, 300, 300)];
    [_unityView addSubview:floatViewController.view];
    [floatViewController.view setFrame:CGRectMake(100, 100, 100, 100)];
    // 把根视图和控制器全部换成我们自定义的内容。
    //_rootController = viewController;
    _rootView = _unityView;
    
    //[[ScreenRecorder Instance] Init];
    //[[ScreenRecorder Instance] Start:YES];
}

@end

IMPL_APP_CONTROLLER_SUBCLASS(ReplayKitLiveAppController)
