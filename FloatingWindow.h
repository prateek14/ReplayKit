#import <UIKit/UIKit.h>


@interface FloatingWindow : UIWindow

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

//  warning: frame的长宽必须相等
- (instancetype)initWithFrame:(CGRect)frame mainImageName:(NSString*)name imagesAndTitle:(NSDictionary*)imagesAndTitle bgcolor:(UIColor *)bgcolor;
// 长按雷达辐射效果
- (instancetype)initWithFrame:(CGRect)frame mainImageName:(NSString*)name imagesAndTitle:(NSDictionary*)imagesAndTitle bgcolor:(UIColor *)bgcolor animationColor:animationColor;
- (void)showWindow;
- (void)dissmissWindow;

@end
