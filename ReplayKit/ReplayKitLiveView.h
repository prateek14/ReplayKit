#import <UIKit/UIKit.h>

@interface ReplayKitLiveView : UIView

typedef enum
{
    FloatingButton_Live = 0,
    FloatingButton_Pause = FloatingButton_Live + 1,
    FloatingButton_Micphone = FloatingButton_Live + 2,
    FloatingButton_Webcam = FloatingButton_Live + 3,
    FloatingButton_Stop = FloatingButton_Live + 4,
} FloatingButtonIndex;

@property (nonatomic,copy) void(^clickBolcks)(FloatingButtonIndex i);

+ (UIImage *)getImageFromBundle:(NSString *)imgName;
+ (UIImage *)getImageFromBundle:(NSString *)imgName ext:(NSString*)extName;

- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor;
- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor animationColor:animationColor;

- (BOOL)isWindowShow;
- (void)showWindow;
- (void)dissmissWindow;

- (void)setupVMObserver:(NSObject *)liveVM;

@end
