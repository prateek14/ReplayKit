#import "ReplayKit+LiveViewController.h"

@implementation ReplayKitLiveViewController

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger ret = [[UnityGetGLView() window] rootViewController].supportedInterfaceOrientations;
    NSLog(@"supportedInterfaceOrientations:%lul", (unsigned long)ret);
    return ret;//(1 << UIInterfaceOrientationLandscapeLeft);
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self presentViewController:[UIViewController new]
//                       animated:NO
//                     completion:^{
//                         [self dismissViewControllerAnimated:NO completion:nil];
//                     }];
//}

@end
