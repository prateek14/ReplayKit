#import <UIKit/UIKit.h>
#import <ReplayKit/ReplayKit.h>
#import "ReplayKitLiveView.h"

@interface ReplayKitLiveViewController : UIViewController
@property (strong, nonatomic) ReplayKitLiveView *liveView;

+ (nullable instancetype)Instance;

@end
