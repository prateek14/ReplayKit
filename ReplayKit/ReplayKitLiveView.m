#import "ReplayKitLiveView.h"
#import "ImageLoader.h"
#import "FloatingWindow.h"

@interface ReplayKitLiveView()

@property(nonatomic)NSInteger frameWidth;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UIColor *bgcolor;
@property(nonatomic,strong)UIColor *animationColor;

@property (strong, nonatomic) ReplayKitLiveViewModel *liveVM;
@property (strong, nonatomic) UIButton *liveButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *micButton;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *stopButton;

@property (assign, nonatomic) BOOL menuOpen;

@end

@implementation ReplayKitLiveView

- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor{
    return  [self initWithFrame:frame bgcolor:bgcolor animationColor:nil];
}

- (instancetype)initWithFrame:(CGRect)frame bgcolor:(UIColor *)bgcolor animationColor:animationColor
{
    if(self = [super initWithFrame:frame])
    {
        _menuOpen = NO;
        
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;  //如果想在 alert 之上，则改成 + 2
        _bgcolor = bgcolor;
        _frameWidth = frame.size.width;
        _animationColor = animationColor;
        
        _contentView = [[UIView alloc] initWithFrame:(CGRect){_frameWidth ,0, 5 * (_frameWidth + 5),_frameWidth}];
        _contentView.alpha  = 0;
        
        [self addSubview:_contentView];
        [self setupViews];
    }
    return self;
}

- (void)dissmissWindow{
    self.hidden = YES;
}
- (void)showWindow{
    self.hidden = NO;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    UIImage *backImage = [ImageLoader imageNamed:@"background"];
    UIImageView *back = [[UIImageView alloc] initWithImage:backImage];
    [self addSubview:back];
    //[back mas_makeConstraints:^(MASConstraintMaker *make) {
    //    make.edges.equalTo(self);
    //}];
    
    self.liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.liveButton.tag = FloatingButton_Live;
    self.pauseButton.tag = FloatingButton_Pause;
    self.micButton.tag = FloatingButton_Micphone;
    self.cameraButton.tag = FloatingButton_Webcam;
    self.stopButton.tag = FloatingButton_Stop;
}

- (void)itemsClick:(id)sender{
    UIButton *button = (UIButton *)sender;
    switch(button.tag)
    {
        case FloatingButton_Live:
            if (!self.liveVM.isLiving) {
                [self.liveButton setImage:[ImageLoader imageNamed:@"live_on"] forState:UIControlStateNormal];
                [self.liveVM start];
            }
            else {
                [self.stopButton setImage:[ImageLoader imageNamed:@"stop"] forState:UIControlStateNormal];
                if (self.menuOpen) {
                    [self setupCloseMenu];
                }
                else {
                    [self setupOpenMenu];
                }
            }
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
            if (self.menuOpen) {
                [self setupCloseMenu];
            }
            break;
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UIImage* image = [ImageLoader imageNamed:@"camera_on"];
    NSLog(@"%@", image);
    if([keyPath isEqualToString:@"cameraEnabled"])
    {
        if (self.liveVM.isCameraEnabled) {
            [self.cameraButton setImage:[ImageLoader imageNamed:@"camera_on"] forState:UIControlStateNormal];
        }
        else {
            [self.cameraButton setImage:[ImageLoader imageNamed:@"camera_off"] forState:UIControlStateNormal];
        }
    }
    else if([keyPath isEqualToString:@"microphoneEnabled"])
    {
        if (self.liveVM.isMicrophoneEnabled) {
            [self.micButton setImage:[ImageLoader imageNamed:@"mic_on"] forState:UIControlStateNormal];
        }
        else {
            [self.micButton setImage:[ImageLoader imageNamed:@"mic_off"] forState:UIControlStateNormal];
        }
    }
    else if([keyPath isEqualToString:@"living"])
    {
        if (self.liveVM.isLiving) {
            UIImage *liveImage = [UIImage animatedImageNamed:@"living" duration:1];
            [self.liveButton setImage:liveImage forState:UIControlStateNormal];
        }
        else {
            [self.liveButton setImage:[ImageLoader imageNamed:@"live_off"] forState:UIControlStateNormal];
        }
    }
    else if([keyPath isEqualToString:@"paused"])
    {
        if (self.liveVM.isPaused) {
            [self.pauseButton setImage:[ImageLoader imageNamed:@"resume"] forState:UIControlStateNormal];
        }
        else {
            [self.pauseButton setImage:[ImageLoader imageNamed:@"pause"] forState:UIControlStateNormal];
        }
    }
}
- (void)setupVMObserver {
    
    [self.liveVM addObserver:self forKeyPath:@"cameraEnabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"microphoneEnabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"living" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"paused" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self setupCloseMenu];
}

- (void)bindVM:(ReplayKitLiveViewModel *)liveVM {
    self.liveVM = liveVM;
    [self setupVMObserver];
}

- (void)closeMenus {
    if (self.liveButton.superview) { [self.liveButton removeFromSuperview]; }
    if (self.pauseButton.superview) { [self.liveButton removeFromSuperview]; }
    if (self.micButton.superview) { [self.liveButton removeFromSuperview]; }
    if (self.cameraButton.superview) { [self.liveButton removeFromSuperview]; }
    if (self.stopButton.superview) { [self.liveButton removeFromSuperview]; }
}

- (void)setupOpenMenu {
    [self closeMenus];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.micButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.liveButton.tag = FloatingButton_Live;
        self.pauseButton.tag = FloatingButton_Pause;
        self.micButton.tag = FloatingButton_Micphone;
        self.cameraButton.tag = FloatingButton_Webcam;
        self.stopButton.tag = FloatingButton_Stop;
        
        [self.liveButton setFrame: CGRectMake(self.frame.size.width, 0, self.frame.size.width , self.frame.size.width)];
        [self.contentView addSubview:_liveButton];
        [self.pauseButton setFrame: CGRectMake(self.frame.size.width * 1, 0, self.frame.size.width , self.frame.size.width)];
        [self addSubview:_pauseButton];
        [self.micButton setFrame: CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width , self.frame.size.width)];
        [self.contentView addSubview:_micButton];
        [self.cameraButton setFrame: CGRectMake(self.frame.size.width * 3, 0, self.frame.size.width , self.frame.size.width)];
        [self.contentView addSubview:_cameraButton];
        [self.stopButton setFrame: CGRectMake(self.frame.size.width * 4, 0, self.frame.size.width , self.frame.size.width)];
        [self.contentView addSubview:_stopButton];
        [self.liveButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.pauseButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.micButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.stopButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.menuOpen = YES;
    }];
}

- (void)setupCloseMenu {
    [self closeMenus];
    [UIView animateWithDuration:0.3 animations:^{
        self.liveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.liveButton.tag = FloatingButton_Live;
        [self.liveButton setFrame: CGRectMake(self.frame.size.width, 0, self.frame.size.width , self.frame.size.width)];
        [self.contentView addSubview:_liveButton];
        [self.liveButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.menuOpen = NO;
    }];
}

@end
