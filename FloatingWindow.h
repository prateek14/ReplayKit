#import <UIKit/UIKit.h>

@interface FloatingWindow : UIWindow

@property (nonatomic,copy) void(^clickBolcks)(NSInteger i);

+ (UIImage *)getImageFromBundle:(NSString *)imgName;
+ (UIImage *)getImageFromBundle:(NSString *)imgName ext:(NSString*)extName;

//  warning: frame的长宽必须相等
- (instancetype)initWithFrame:(CGRect)frame mainImageName:(NSString*)name imagesAndTitle:(NSDictionary*)imagesAndTitle bgcolor:(UIColor *)bgcolor;
// 长按雷达辐射效果
- (instancetype)initWithFrame:(CGRect)frame mainImageName:(NSString*)name imagesAndTitle:(NSDictionary*)imagesAndTitle bgcolor:(UIColor *)bgcolor animationColor:animationColor;
- (void)showWindow;
- (void)dissmissWindow;

@end
