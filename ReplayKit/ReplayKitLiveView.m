#import "ReplayKitLiveView.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define animateDuration 0.3         //位置改变动画时间
#define showDuration 0.1            //展开动画时间
#define statusChangeDuration  3.0   //状态改变时间
#define normalAlpha  0.8            //正常状态时背景alpha值
#define sleepAlpha  0.3             //隐藏到边缘时的背景alpha值
#define myBorderWidth 1.0           //外框宽度
#define margin  5                   //间隔
#define liveButtonFixWidth 15
#define liveButtonFixHeight 10


#define WZFlashInnerCircleInitialRaius  20

@interface ReplayKitLiveView()

@property (strong, nonatomic) ReplayKitLiveViewModel *liveVM;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIButton *liveButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *micButton;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *stopButton;

@property(nonatomic)BOOL  isShowTab;
@property(nonatomic,strong)UIPanGestureRecognizer *pan;
//@property(nonatomic,strong)UITapGestureRecognizer *tap;
//@property(nonatomic,strong)UIColor *bgcolor;
//@property(nonatomic,strong)CAAnimationGroup *animationGroup;
//@property(nonatomic,strong)CAShapeLayer *circleShape;
//@property(nonatomic,strong)UIColor *animationColor;
@property(nonatomic)CGPoint startPanOffset;

+ (ReplayKitLiveView*)Instance;

@end

static ReplayKitLiveView* _instance = nil;

@implementation ReplayKitLiveView

+ (ReplayKitLiveView*)Instance
{
    return _instance;
}

+ (UIImage *)getImageFromBundle:(NSString *)imgName{
    return [ReplayKitLiveView getImageFromBundle:imgName ext:@"png"];
}

+ (UIImage *)getImageFromBundle:(NSString *)imgName ext:(NSString*)extName
{
    NSString *path = [[ NSBundle mainBundle] pathForResource: @ "image" ofType:@ "bundle"];
    //NSLog(@"%@", path);
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *img_path = [bundle pathForResource:imgName ofType:extName];
    return [UIImage imageWithContentsOfFile:img_path];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(_instance)
        return _instance;
    self = [super initWithFrame:frame];
    _instance = self;
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor{
    return  [self initWithFrame:frame bgcolor:bgcolor animationColor:nil];
}

- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor animationColor:animationColor
{
    if(_instance)
        return _instance;
    if(self = [super initWithFrame:frame])
    {
        _isShowTab = FALSE;

        //self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert + 1;  //如果想在 alert 之上，则改成 + 2
        
        //_bgcolor = bgcolor;
        self.backgroundColor = [UIColor grayColor];
        //_animationColor = animationColor;
        
        _liveButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [ReplayKitLiveView getImageFromBundle:@"live_off"];
        [_liveButton setFrame:(CGRect){0, 0, frame.size.width, frame.size.height - (liveButtonFixWidth - liveButtonFixHeight)}];
        [_liveButton setImage:image forState:UIControlStateNormal];
        _liveButton.tag = FloatingButton_Live;
        [_liveButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat buttonSize = _liveButton.frame.size.width;
        _contentView = [[UIView alloc] initWithFrame:(CGRect){margin, liveButtonFixHeight / 2, buttonSize + 4 * (frame.size.width - liveButtonFixWidth + margin) - margin, buttonSize - liveButtonFixWidth}];
        _contentView.alpha  = 0;
        [self addSubview:_contentView];
        //添加按钮
        [self setButtons];
        [self addSubview:_liveButton];
        
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        _pan.delaysTouchesBegan = NO;
        [self addGestureRecognizer:_pan];
        //_tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        //[self addGestureRecognizer:_tap];
        //设备旋转
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    _instance = self;
    return self;
}

- (BOOL)isWindowShow
{
    return !self.hidden;
}
- (void)dissmissWindow{
    self.hidden = YES;
}
- (void)showWindow{
    self.hidden = NO;
}

- (void)setButtons{
    CGFloat width = self.frame.size.width - liveButtonFixWidth;
    UIImage* image = [ReplayKitLiveView getImageFromBundle:@"live_adorn"];
    image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.35 topCapHeight:image.size.height * 0.5];
    self.background = [[UIImageView alloc] initWithImage:image];
    [self.background setFrame: CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height)];
    [self.contentView addSubview:_background];
    
    CGFloat startPosX = _liveButton.frame.size.width;
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.pauseButton setFrame: CGRectMake(startPosX, 0, width, width)];
    [self.micButton setFrame: CGRectMake(startPosX + width + margin, 0, width, width)];
    [self.cameraButton setFrame: CGRectMake(startPosX + (width + margin) * 2, 0, width, width)];
    [self.stopButton setFrame: CGRectMake(startPosX + (width + margin) * 3, 0, width, width)];
    
    [self.cameraButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_camera_on"] forState:UIControlStateNormal];
    [self.micButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_microphone_on"] forState:UIControlStateNormal];
    [self.pauseButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_pause"] forState:UIControlStateNormal];
    [self.stopButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_stop"] forState:UIControlStateNormal];
    
    self.pauseButton.tag = FloatingButton_Pause;
    self.micButton.tag = FloatingButton_Micphone;
    self.cameraButton.tag = FloatingButton_Webcam;
    self.stopButton.tag = FloatingButton_Stop;
    
    [self.pauseButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.micButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_pauseButton];
    [self.contentView addSubview:_micButton];
    [self.contentView addSubview:_cameraButton];
    [self.contentView addSubview:_stopButton];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"cameraEnabled"])
    {
        if (self.liveVM.isCameraEnabled) {
            [self.cameraButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_camera_off"] forState:UIControlStateNormal];
        }
        else {
            [self.cameraButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_camera_on"] forState:UIControlStateNormal];
        }
    }
    else if([keyPath isEqualToString:@"microphoneEnabled"])
    {
        if (self.liveVM.isMicrophoneEnabled) {
            [self.micButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_microphone_off"] forState:UIControlStateNormal];
        }
        else {
            [self.micButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_microphone_on"] forState:UIControlStateNormal];
        }
    }
    else if([keyPath isEqualToString:@"living"])
    {
        if (self.liveVM.isLiving) {
            UIImage *liveImage = [ReplayKitLiveView getImageFromBundle:@"live_on"];
            [self.liveButton setImage:liveImage forState:UIControlStateNormal];
            [self onOpenTab];
        }
        else {
            [self.liveButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_off"] forState:UIControlStateNormal];
            [self onCloseTab];
        }
    }
    else if([keyPath isEqualToString:@"paused"])
    {
        if (self.liveVM.isPaused) {
            [self.pauseButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_play"] forState:UIControlStateNormal];
        }
        else {
            [self.pauseButton setImage:[ReplayKitLiveView getImageFromBundle:@"live_pause"] forState:UIControlStateNormal];
        }
    }
}
- (void)setupVMObserver:(ReplayKitLiveViewModel *)liveVM {
    
    self.liveVM = liveVM;
    [self.liveVM addObserver:self forKeyPath:@"cameraEnabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"microphoneEnabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"living" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"paused" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

//改变位置
- (void)locationChange:(UIPanGestureRecognizer*)p
{
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(p.state == UIGestureRecognizerStateBegan)
    {
        //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
        self.startPanOffset = CGPointMake(panPoint.x - self.center.x, panPoint.y - self.center.y);
    }
    if(p.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x - self.startPanOffset.x
                                  , panPoint.y - self.startPanOffset.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded)
    {
        //[self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];
        [self fixedBound];
    }
}
/*
- (void)changeStatus
{
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat x = self.center.x < 20+WIDTH/2 ? 0 :  self.center.x > kScreenWidth - 20 -WIDTH/2 ? kScreenWidth : self.center.x;
        CGFloat y = self.center.y < 40 + HEIGHT/2 ? 0 : self.center.y > kScreenHeight - 40 - HEIGHT/2 ? kScreenHeight : self.center.y;
        
        if((x == 0 && y ==0) || (x == kScreenWidth && y == 0) || (x == 0 && y == kScreenHeight) || (x == kScreenWidth && y == kScreenHeight)){
            y = self.center.y;
        }
        self.center = CGPointMake(x, y);
    }];
}
 */

#pragma mark ------- contentview 操作 --------------------
- (void)fixedBound
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat left = width / 2 + margin;
    CGFloat right = kScreenWidth - (width / 2 + margin);
    CGFloat top = height / 2 + margin;
    CGFloat bottom = kScreenHeight - (height / 2 + margin);
    if (self.center.x < left) {
        [UIView animateWithDuration:animateDuration animations:^{
            self.center = CGPointMake(left, self.center.y);
        }];
    }else if (self.center.x > right) {
        [UIView animateWithDuration:animateDuration animations:^{
            self.center = CGPointMake(right, self.center.y);
        }];
    }
    if (self.center.y < top) {
        [UIView animateWithDuration:animateDuration animations:^{
            self.center = CGPointMake(self.center.x, top);
        }];
    }else if (self.center.y > bottom) {
        [UIView animateWithDuration:animateDuration animations:^{
            self.center = CGPointMake(self.center.x, bottom);
        }];
    }
    NSLog(@"self.center=%f,%f", self.center.x,self.center.y);
}
- (void)onCloseTab
{
    if(!self.isShowTab)
        return;
    self.isShowTab = NO;
    [UIView animateWithDuration:showDuration animations:^{
        _contentView.alpha  = 0;
        CGFloat height = self.frame.size.height;
        CGSize buttonSize = self.liveButton.frame.size;
        if (self.frame.origin.x + self.liveButton.frame.origin.x <= kScreenWidth/2) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, height, height);
        }else{
            CGFloat width = self.frame.size.width;
            //self.liveButton.frame = CGRectMake(0, 0, self.liveButton.frame.size.width, self.liveButton.frame.size.height);
            //self.frame = CGRectMake(_stopButton.frame.origin.x, _stopButton.frame.origin.y, height, height);
            self.liveButton.frame = CGRectMake(_contentView.frame.size.width - buttonSize.width - 2 * margin, 0, buttonSize.width, buttonSize.height);
            self.frame = CGRectMake(self.frame.origin.x - 5 * (width + margin + liveButtonFixWidth), self.frame.origin.y, height, height);
        }
        //self.backgroundColor = [UIColor clearColor];
    }];
    [self fixedBound];
    //[self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];
    CGRect rect = self.frame;
    NSLog(@"onCloseTab:self.frame=%f,%f,%f,%f", rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
}
- (void)onOpenTab
{
    if(self.isShowTab)
        return;
    self.isShowTab = YES;
    [UIView animateWithDuration:showDuration animations:^{
        _contentView.alpha  = 1;
        CGFloat height = self.frame.size.height;
        CGSize buttonSize = self.liveButton.frame.size;
        if (self.frame.origin.x <= kScreenWidth/2) {
            //按钮在屏幕左边时，contentview恢复默认
            _contentView.frame = CGRectMake(margin, liveButtonFixHeight / 2, buttonSize.width + 4 * (self.frame.size.width - liveButtonFixWidth + margin) - margin, buttonSize.width - liveButtonFixWidth);
            [self.background setFrame: CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height)];
            [_liveButton setFrame:(CGRect){0, 0, buttonSize.width, buttonSize.height}];
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _contentView.frame.size.width, height);
        }else{
            CGFloat width = self.frame.size.width;
            //按钮在屏幕右边时，左移contentview
            _contentView.frame = CGRectMake(-(buttonSize.width + 2 * margin), liveButtonFixHeight / 2, buttonSize.width + 4 * (self.frame.size.width - liveButtonFixWidth + margin) - margin, buttonSize.width - liveButtonFixWidth);
            [self.background setFrame: CGRectMake(buttonSize.width, 0, _contentView.frame.size.width, _contentView.frame.size.height)];
            self.liveButton.frame = CGRectMake(_contentView.frame.size.width - buttonSize.width - 2 * margin, 0, buttonSize.width, buttonSize.height);
            self.frame = CGRectMake(self.frame.origin.x - 5 * (width + margin + liveButtonFixWidth), self.frame.origin.y, _contentView.frame.size.width, height);
        }
    }];
    [self fixedBound];
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
    CGRect rect = self.frame;
    NSLog(@"onOpenTab:self.frame=%f,%f,%f,%f", rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
}
#pragma mark  ------- button事件 ---------
- (void)itemsClick:(id)sender{
    UIButton *button = (UIButton *)sender;
    switch(button.tag)
    {
        case FloatingButton_Live:
            /*
            if (!self.liveVM.isLiving) {
                [self.liveVM start];
            }
            else {
                if (self.isShowTab) {
                    [self onCloseTab];
                }
                else {
                    [self onOpenTab];
                }
            }
             */
            [self onOpenTab];
            break;
        case FloatingButton_Pause:
            if (self.liveVM.isPaused) {
                [self.liveVM resume];
            }
            else {
                [self.liveVM pause];
            }
            break;
        case FloatingButton_Micphone:
            self.liveVM.microphoneEnabled = !self.liveVM.isMicrophoneEnabled;
            break;
        case FloatingButton_Webcam:
            self.liveVM.cameraEnabled = !self.liveVM.isCameraEnabled;
            break;
        case FloatingButton_Stop:
            if (self.liveVM.isLiving) {
                [self.liveVM stop];
            }
            if (self.isShowTab) {
                [self onCloseTab];
            }
            break;
    }
    if (self.clickBolcks) {
        self.clickBolcks((FloatingButtonIndex)button.tag);
    }
}
#pragma mark  ------- 设备旋转 -----------
- (void)orientChange:(NSNotification *)notification{
    //旋转前要先改变frame，否则坐标有问题（临时办法）
    self.frame = CGRectMake(0, kScreenHeight - self.frame.origin.y - self.frame.size.height, self.frame.size.width,self.frame.size.height);
}


@end
