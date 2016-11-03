#import "ReplayKit+LiveViewController.h"
#import "FloatingWindow.h"

@interface ReplayKitLiveViewController ()

@property(nonatomic,strong) FloatingWindow *floatWindow;

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
    _floatWindow = [[FloatingWindow alloc]initWithFrame:CGRectMake(0, 200, 50, 50) mainImageName:@"z.png" imagesAndTitle:@{@"ddd":@"用户中心",@"eee":@"退出登录",@"fff":@"客服中心"} bgcolor:[UIColor lightGrayColor] animationColor:[UIColor purpleColor]];
    
    _floatWindow.clickBolcks = ^(NSInteger i){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"第 %ld 个按钮", (long)i] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    };
    _floatWindow.rootViewController = self;
    [_floatWindow makeKeyAndVisible];
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
