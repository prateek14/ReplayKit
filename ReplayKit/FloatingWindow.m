#import "FloatingWindow.h"
#import "ImageLoader.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define animateDuration 0.3       //位置改变动画时间
#define showDuration 0.1          //展开动画时间
#define statusChangeDuration  3.0    //状态改变时间
#define normalAlpha  0.8           //正常状态时背景alpha值
#define sleepAlpha  0.3           //隐藏到边缘时的背景alpha值
#define myBorderWidth 1.0         //外框宽度
#define marginWith  5             //间隔

#define WZFlashInnerCircleInitialRaius  20

@interface FloatingWindow()

@property (strong, nonatomic) ReplayKitLiveViewModel *liveVM;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIButton *liveButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *micButton;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *stopButton;

@property(nonatomic)NSInteger frameWidth;
@property(nonatomic)BOOL  isShowTab;
@property(nonatomic,strong)UIPanGestureRecognizer *pan;
@property(nonatomic,strong)UITapGestureRecognizer *tap;
@property(nonatomic,strong)UIColor *bgcolor;
@property(nonatomic,strong)CAAnimationGroup *animationGroup;
@property(nonatomic,strong)CAShapeLayer *circleShape;
@property(nonatomic,strong)UIColor *animationColor;

@end

@implementation FloatingWindow

+ (UIImage *)getImageFromBundle:(NSString *)imgName{
    return [FloatingWindow getImageFromBundle:imgName ext:@"png"];
}

+ (UIImage *)getImageFromBundle:(NSString *)imgName ext:(NSString*)extName
{
    NSString *path = [[ NSBundle mainBundle] pathForResource: @ "image" ofType:@ "bundle"];
    NSLog(@"%@", path);
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSString *img_path = [bundle pathForResource:imgName ofType:extName];
    return [UIImage imageWithContentsOfFile:img_path];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame mainImageName:(NSString*)name imagesAndTitle:(NSDictionary*)imagesAndTitle bgcolor:(UIColor *)bgcolor{
    return  [self initWithFrame:frame mainImageName:name imagesAndTitle:imagesAndTitle bgcolor:bgcolor animationColor:nil];
}

- (instancetype)initWithFrame:(CGRect)frame mainImageName:(NSString *)mainImageName imagesAndTitle:(NSDictionary*)imagesAndTitle bgcolor:(UIColor *)bgcolor animationColor:animationColor
{
    if(self = [super initWithFrame:frame])
    {
        NSAssert(mainImageName != nil, @"mainImageName can't be nil !");
        NSAssert(imagesAndTitle != nil, @"imagesAndTitle can't be nil !");
        
        _isShowTab = FALSE;

        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert;  //如果想在 alert 之上，则改成 + 2
        //self.rootViewController = [UIViewController new];
        //[self makeKeyAndVisible];
        
        _bgcolor = bgcolor;
        _frameWidth = frame.size.width;
        _animationColor = animationColor;
        
        _contentView = [[UIView alloc] initWithFrame:(CGRect){_frameWidth ,0,imagesAndTitle.count * (_frameWidth + 5),_frameWidth}];
        _contentView.alpha  = 0;
        [self addSubview:_contentView];
        //添加按钮
        [self setButtons];
        
        _liveButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_liveButton setFrame:(CGRect){0, 0,frame.size.width, frame.size.height}];
        UIImage *image = [ImageLoader imageNamed:@"live_off"];//[FloatingWindow getImageFromBundle:mainImageName];
        NSLog(@"%@-%@", mainImageName, image);
        [_liveButton setImage:image forState:UIControlStateNormal];
        //_liveButton.alpha = sleepAlpha;
        //[_liveButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        //if (_animationColor) {
        //    [_liveButton addTarget:self action:@selector(mainBtnTouchDown) forControlEvents:UIControlEventTouchDown];
        //}
        _liveButton.tag = FloatingButton_Live;
        [_liveButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_liveButton];

        //[self doBorderWidth:myBorderWidth color:nil cornerRadius:_frameWidth/2];
        
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        _pan.delaysTouchesBegan = NO;
        [self addGestureRecognizer:_pan];
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        [self addGestureRecognizer:_tap];
        
        //设备旋转的时候收回按钮
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dissmissWindow{
    self.hidden = YES;
}
- (void)showWindow{
    self.hidden = NO;
}

- (void)setButtons{
    /*
    int i = FloatingButton_Live + 1;
    for (NSString *key in _imagesAndTitle) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame: CGRectMake(self.frameWidth * i , 0, self.frameWidth , self.frameWidth )];
        [button setBackgroundColor:[UIColor clearColor]];
        
        UIImage *image = [ImageLoader imageNamed:@"live_off"];//[FloatingWindow getImageFromBundle:key];
        [button setTitle:_imagesAndTitle[key] forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        
        button.tag = i;
        
        // 则默认image在左，title在右
        // 改成image在上，title在下
        button.titleEdgeInsets = UIEdgeInsetsMake(self.frameWidth/2 , -image.size.width, 0.0, 0.0);
        button.imageEdgeInsets = UIEdgeInsetsMake(2.0, 8.0, 16.0, -
                                                       button.titleLabel.bounds.size.width + 8);
        button.titleLabel.font = [UIFont systemFontOfSize: self.frameWidth/5];
        [button addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:button];
        i++;
    };
     */
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.micButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.pauseButton setFrame: CGRectMake(0, 0, self.frameWidth , self.frameWidth )];
    [self.micButton setFrame: CGRectMake(self.frameWidth * 1, 0, self.frameWidth , self.frameWidth )];
    [self.cameraButton setFrame: CGRectMake(self.frameWidth * 2, 0, self.frameWidth , self.frameWidth )];
    [self.stopButton setFrame: CGRectMake(self.frameWidth * 3, 0, self.frameWidth , self.frameWidth )];
    
    [self.cameraButton setImage:[ImageLoader imageNamed:@"camera_off"] forState:UIControlStateNormal];
    [self.micButton setImage:[ImageLoader imageNamed:@"mic_off"] forState:UIControlStateNormal];
    [self.pauseButton setImage:[ImageLoader imageNamed:@"pause"] forState:UIControlStateNormal];
    [self.stopButton setImage:[ImageLoader imageNamed:@"stop"] forState:UIControlStateNormal];
    
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
            [self onOpenTab];
        }
        else {
            [self.liveButton setImage:[ImageLoader imageNamed:@"live_off"] forState:UIControlStateNormal];
            [self onCloseTab];
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
- (void)setupVMObserver:(ReplayKitLiveViewModel *)liveVM {
    
    self.liveVM = liveVM;
    [self.liveVM addObserver:self forKeyPath:@"cameraEnabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"microphoneEnabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"living" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self.liveVM addObserver:self forKeyPath:@"paused" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

#pragma mark ------- contentview 操作 --------------------
//按钮在屏幕右边时，左移contentview
- (void)moveContentviewLeft{
    _contentView.frame = (CGRect){self.frameWidth/3, 0 ,_contentView.frame.size.width,_contentView.frame.size.height};
}

//按钮在屏幕左边时，contentview恢复默认
- (void)resetContentview{
    _contentView.frame = (CGRect){self.frameWidth + marginWith,0,_contentView.frame.size.width,_contentView.frame.size.height};
}


#pragma mark  ------- 绘图操作 ----------
- (void)drawRect:(CGRect)rect {
    [self drawDash];
}
//分割线
- (void)drawDash{
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 0.1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGFloat lengths[] = {2,1};
    CGContextSetLineDash(context, 0, lengths,2);
    for (int i = 1; i < 4; i++){
        CGContextMoveToPoint(context, self.contentView.frame.origin.x + i * self.frameWidth, marginWith * 2);
        CGContextAddLineToPoint(context, self.contentView.frame.origin.x + i * self.frameWidth, self.frameWidth - marginWith * 2);
    }
    CGContextStrokePath(context);
}

//改变位置
- (void)locationChange:(UIPanGestureRecognizer*)p
{
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    if(p.state == UIGestureRecognizerStateBegan)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
        //_liveButton.alpha = normalAlpha;
    }
    if(p.state == UIGestureRecognizerStateChanged)
    {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded)
    {
        //[self stopAnimation];
        [self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];
        /*
        if(panPoint.x <= kScreenWidth/2)
        {
            if(panPoint.y <= 40+HEIGHT/2 && panPoint.x >= 20+WIDTH/2)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2);
                }];
            }
            else if(panPoint.y >= kScreenHeight-HEIGHT/2-40 && panPoint.x >= 20+WIDTH/2)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-HEIGHT/2);
                }];
            }
            else if (panPoint.x < WIDTH/2+20 && panPoint.y > kScreenHeight-HEIGHT/2)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(WIDTH/2, kScreenHeight-HEIGHT/2);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y < HEIGHT/2 ? HEIGHT/2 :panPoint.y;
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(WIDTH/2, pointy);
                }];
            }
        }
        else if(panPoint.x > kScreenWidth/2)
        {
            if(panPoint.y <= 40+HEIGHT/2 && panPoint.x < kScreenWidth-WIDTH/2-20 )
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(panPoint.x, HEIGHT/2);
                }];
            }
            else if(panPoint.y >= kScreenHeight-40-HEIGHT/2 && panPoint.x < kScreenWidth-WIDTH/2-20)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(panPoint.x, kScreenHeight-HEIGHT/2);
                }];
            }
            else if (panPoint.x > kScreenWidth-WIDTH/2-20 && panPoint.y < HEIGHT/2)
            {
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(kScreenWidth-WIDTH/2, HEIGHT/2);
                }];
            }
            else
            {
                CGFloat pointy = panPoint.y > kScreenHeight-HEIGHT/2 ? kScreenHeight-HEIGHT/2 :panPoint.y;
                [UIView animateWithDuration:animateDuration animations:^{
                    self.center = CGPointMake(kScreenWidth-WIDTH/2, pointy);
                }];
            }
        }
         */
    }
}
//点击事件
- (void)click:(UITapGestureRecognizer*)p
{
    /*
    [self stopAnimation];
    
    _liveButton.alpha = normalAlpha;
    
    //拉出悬浮窗
    if (self.center.x == 0) {
        self.center = CGPointMake(WIDTH/2, self.center.y);
    }else if (self.center.x == kScreenWidth) {
        self.center = CGPointMake(kScreenWidth - WIDTH/2, self.center.y);
    }else if (self.center.y == 0) {
        self.center = CGPointMake(self.center.x, HEIGHT/2);
    }else if (self.center.y == kScreenHeight) {
        self.center = CGPointMake(self.center.x, kScreenHeight - HEIGHT/2);
    }
    //展示按钮列表
    if (!self.isShowTab) {
        self.isShowTab = TRUE;
        
        //为了主按钮点击动画
        self.layer.masksToBounds = YES;
        
        [UIView animateWithDuration:showDuration animations:^{
            
            _contentView.alpha  = 1;
            
            if (self.frame.origin.x <= kScreenWidth/2) {
                [self resetContentview];
                
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, WIDTH + 4 * (self.frameWidth + marginWith) ,self.frameWidth);
            }else{
                
                [self moveContentviewLeft];
                
                self.liveButton.frame = CGRectMake((4 * (self.frameWidth + marginWith)), 0, self.frameWidth, self.frameWidth);
                self.frame = CGRectMake(self.frame.origin.x  - 4 * (self.frameWidth + marginWith), self.frame.origin.y, (WIDTH + 4 * (self.frameWidth + marginWith)) ,self.frameWidth);
            }
            if (_bgcolor) {
                self.backgroundColor = _bgcolor;
            }else{
                self.backgroundColor = [UIColor grayColor];
            }
        }];
        //移除pan手势
        if (_pan) {
            [self removeGestureRecognizer:_pan];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
    }else{
        self.isShowTab = FALSE;
        
        //为了主按钮点击动画
        self.layer.masksToBounds = NO;
        
        //添加pan手势
        if (_pan) {
            [self addGestureRecognizer:_pan];
        }
        
        [UIView animateWithDuration:showDuration animations:^{
            
            _contentView.alpha  = 0;
            
            if (self.frame.origin.x + self.liveButton.frame.origin.x <= kScreenWidth/2) {
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frameWidth ,self.frameWidth);
            }else{
                self.liveButton.frame = CGRectMake(0, 0, self.frameWidth, self.frameWidth);
                self.frame = CGRectMake(self.frame.origin.x + 4 * (self.frameWidth + marginWith), self.frame.origin.y, self.frameWidth ,self.frameWidth);
            }
            self.backgroundColor = [UIColor clearColor];
        }];
        [self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];
    }
     */
}

- (void)changeStatus
{
    //[UIView animateWithDuration:1.0 animations:^{
    //    _liveButton.alpha = sleepAlpha;
    //}];
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat x = self.center.x < 20+WIDTH/2 ? 0 :  self.center.x > kScreenWidth - 20 -WIDTH/2 ? kScreenWidth : self.center.x;
        CGFloat y = self.center.y < 40 + HEIGHT/2 ? 0 : self.center.y > kScreenHeight - 40 - HEIGHT/2 ? kScreenHeight : self.center.y;
        
        //禁止停留在4个角
        if((x == 0 && y ==0) || (x == kScreenWidth && y == 0) || (x == 0 && y == kScreenHeight) || (x == kScreenWidth && y == kScreenHeight)){
            y = self.center.y;
        }
        self.center = CGPointMake(x, y);
    }];
}

/*
- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius{
  //  self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = width;
    if (!color) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
    }else{
        self.layer.borderColor = color.CGColor;
    }
}
 */

#pragma mark  ------- animation -------------

/*
- (void)buttonAnimation{

    self.layer.masksToBounds = NO;
    
    CGFloat scale = 1.0f;
    
    CGFloat width = self.liveButton.bounds.size.width, height = self.liveButton.bounds.size.height;

    CGFloat biggerEdge = width > height ? width : height, smallerEdge = width > height ? height : width;
    CGFloat radius = smallerEdge / 2 > WZFlashInnerCircleInitialRaius ? WZFlashInnerCircleInitialRaius : smallerEdge / 2;
    
    scale = biggerEdge / radius + 0.5;
    _circleShape = [self createCircleShapeWithPosition:CGPointMake(width/2, height/2)
                                                 pathRect:CGRectMake(0, 0, radius * 2, radius * 2)
                                                   radius:radius];

// 圆圈放大效果
//        scale = 2.5f;
//        _circleShape = [self createCircleShapeWithPosition:CGPointMake(width/2, height/2)
//                                                 pathRect:CGRectMake(-CGRectGetMidX(self.mainImageButton.bounds), -CGRectGetMidY(self.mainImageButton.bounds), width, height)
//                                                   radius:self.mainImageButton.layer.cornerRadius];
   
    
    [self.liveButton.layer addSublayer:_circleShape];
    
    CAAnimationGroup *groupAnimation = [self createFlashAnimationWithScale:scale duration:1.0f];
    
    [_circleShape addAnimation:groupAnimation forKey:nil];
}

- (void)stopAnimation{
  
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(buttonAnimation) object:nil];
    
    if (_circleShape) {
        [_circleShape removeFromSuperlayer];
    }
}
- (CAShapeLayer *)createCircleShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect radius:(CGFloat)radius
{
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = [self createCirclePathWithRadius:rect radius:radius];
    circleShape.position = position;
    

    circleShape.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    circleShape.fillColor = _animationColor.CGColor;

//  圆圈放大效果
//  circleShape.fillColor = [UIColor clearColor].CGColor;
//  circleShape.strokeColor = [UIColor purpleColor].CGColor;

    circleShape.opacity = 0;
    circleShape.lineWidth = 1;
    
    return circleShape;
}
- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration
{
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    _animationGroup = [CAAnimationGroup animation];
    _animationGroup.animations = @[scaleAnimation, alphaAnimation];
    _animationGroup.duration = duration;
    _animationGroup.repeatCount = INFINITY;
    _animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return _animationGroup;
 }


- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius
{
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
 }
 */
- (void)onCloseTab
{
    self.isShowTab = NO;
    
    if (self.center.x == 0) {
        self.center = CGPointMake(WIDTH/2, self.center.y);
    }else if (self.center.x == kScreenWidth) {
        self.center = CGPointMake(kScreenWidth - WIDTH/2, self.center.y);
    }else if (self.center.y == 0) {
        self.center = CGPointMake(self.center.x, HEIGHT/2);
    }else if (self.center.y == kScreenHeight) {
        self.center = CGPointMake(self.center.x, kScreenHeight - HEIGHT/2);
    }
    //为了主按钮点击动画
    //self.layer.masksToBounds = NO;
    
    //添加pan手势
    //if (_pan) {
    //    [self addGestureRecognizer:_pan];
    //}
    
    [UIView animateWithDuration:showDuration animations:^{
        
        _contentView.alpha  = 0;
        
        if (self.frame.origin.x + self.liveButton.frame.origin.x <= kScreenWidth/2) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frameWidth ,self.frameWidth);
        }else{
            self.liveButton.frame = CGRectMake(0, 0, self.frameWidth, self.frameWidth);
            self.frame = CGRectMake(self.frame.origin.x + 4 * (self.frameWidth + marginWith), self.frame.origin.y, self.frameWidth ,self.frameWidth);
        }
        self.backgroundColor = [UIColor clearColor];
    }];
    [self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];
}
- (void)onOpenTab
{
    self.isShowTab = YES;
    //拉出悬浮窗
    if (self.center.x == 0) {
        self.center = CGPointMake(WIDTH/2, self.center.y);
    }else if (self.center.x == kScreenWidth) {
        self.center = CGPointMake(kScreenWidth - WIDTH/2, self.center.y);
    }else if (self.center.y == 0) {
        self.center = CGPointMake(self.center.x, HEIGHT/2);
    }else if (self.center.y == kScreenHeight) {
        self.center = CGPointMake(self.center.x, kScreenHeight - HEIGHT/2);
    }
    
    //为了主按钮点击动画
    //self.layer.masksToBounds = YES;
    
    [UIView animateWithDuration:showDuration animations:^{
        
        _contentView.alpha  = 1;
        
        if (self.frame.origin.x <= kScreenWidth/2) {
            [self resetContentview];
            
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, WIDTH + 4 * (self.frameWidth + marginWith) ,self.frameWidth);
        }else{
            
            [self moveContentviewLeft];
            
            self.liveButton.frame = CGRectMake((4 * (self.frameWidth + marginWith)), 0, self.frameWidth, self.frameWidth);
            self.frame = CGRectMake(self.frame.origin.x  - 4 * (self.frameWidth + marginWith), self.frame.origin.y, (WIDTH + 4 * (self.frameWidth + marginWith)) ,self.frameWidth);
        }
        if (_bgcolor) {
            self.backgroundColor = _bgcolor;
        }else{
            self.backgroundColor = [UIColor grayColor];
        }
    }];
    //移除pan手势
    //if (_pan) {
    //    [self removeGestureRecognizer:_pan];
    //}
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
}
#pragma mark  ------- button事件 ---------
- (void)itemsClick:(id)sender{
    if (self.isShowTab){
        [self click:nil];
    }
    UIButton *button = (UIButton *)sender;
    switch(button.tag)
    {
        case FloatingButton_Live:
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
/*
- (void)mainBtnTouchDown{
    if (!self.isShowTab) {
        [self performSelector:@selector(buttonAnimation) withObject:nil afterDelay:0.5];
    }
}
*/
#pragma mark  ------- 设备旋转 -----------
- (void)orientChange:(NSNotification *)notification{
    //不设置的话,长按动画那块有问题
    //self.layer.masksToBounds = YES;
    
    //旋转前要先改变frame，否则坐标有问题（临时办法）
    self.frame = CGRectMake(0, kScreenHeight - self.frame.origin.y - self.frame.size.height, self.frame.size.width,self.frame.size.height);
    
    if (self.isShowTab) {
        [self onOpenTab];
    }
}


@end
