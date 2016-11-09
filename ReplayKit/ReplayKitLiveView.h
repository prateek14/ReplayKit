#import <UIKit/UIKit.h>
#import "ReplayKitLiveViewModel.h"

//typedef enum
//{
//    FloatingButton_Live = 0,
//    FloatingButton_Pause = FloatingButton_Live + 1,
//    FloatingButton_Micphone = FloatingButton_Live + 2,
//    FloatingButton_Webcam = FloatingButton_Live + 3,
//    FloatingButton_Stop = FloatingButton_Live + 4,
//} FloatingButtonIndex;

typedef enum : NSUInteger {
    RPMenuLeftDirection,
    RPMenuRightDirection,
    RPMenuUpDirection,
    RPMenuDownDirection,
} RPMenuDirection;

@interface ReplayKitLiveView : UIWindow

- (void)bindVM:(ReplayKitLiveViewModel *)liveVM;

//  warning: frame的长宽必须相等
- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor;
// 长按雷达辐射效果
- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor animationColor:animationColor;

- (void)showWindow;
- (void)dissmissWindow;

@end
