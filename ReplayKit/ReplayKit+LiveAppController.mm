//#import <UIKit/UIKit.h>
//#import "UnityAppController.h"
//#import "UI/UnityView.h"
//#import "UI/UnityViewControllerBase.h"
//#import "ReplayKitLiveViewModel.h"
//
//@interface ReplayKitLiveAppController : UnityAppController
//
////@property (strong, nonatomic) ReplayKitLiveViewController *floatViewController;
//
//@end
//
//@implementation ReplayKitLiveAppController
//
//
//- (void)willStartWithViewController:(UIViewController*)controller {
////    // 新建自定义视图控制器。
////    self.floatViewController = [[ReplayKitLiveViewController alloc] init];
////    // 把Unity的内容视图作为子视图放到我们自定义的视图里面。
////    //[viewController.view addSubview:_unityView];
////    //[_unityView setFrame:CGRectMake(0, 0, 300, 300)];
////    [_unityView addSubview:self.floatViewController.view];
////    [self.floatViewController.view setFrame:_unityView.frame];
////    // 把根视图和控制器全部换成我们自定义的内容。
////    //_rootController = self.floatViewController;
////    _unityView.contentScaleFactor	= UnityScreenScaleFactor([UIScreen mainScreen]);
////    _unityView.autoresizingMask		= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
////    _rootController.view = _rootView = _unityView;
////#if !UNITY_TVOS
////    _rootController.wantsFullScreenLayout = TRUE;
////#endif
//    [ReplayKitLiveViewModel Instance];
//    _rootController.view = _rootView = _unityView;
//}
//
//@end
//
//IMPL_APP_CONTROLLER_SUBCLASS(ReplayKitLiveAppController)
