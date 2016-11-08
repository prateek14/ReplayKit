//
//  RPLiveCtrlView.m
//  Fox
//
//  Created by jinchu darwin on 12/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "ReplayKitLiveView.h"
//#import "ReactiveCocoa/ReactiveCocoa.h"
//#import "Masonry/Masonry.h"
#import "ImageLoader.h"

@interface ReplayKitLiveView()

@property (strong, nonatomic) ReplayKitLiveViewModel *liveVM;
@property (strong, nonatomic) UIButton *liveButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) UIButton *micButton;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *stopButton;

@property (assign, nonatomic) BOOL menuOpen;

@end

@implementation ReplayKitLiveView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonSetup];
}

- (void)commonSetup {
    _menuOpen = NO;
    [self setupViews];
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
    
    [self setupCloseMenu];
    
    self.liveButton.tag = FloatingButton_Live;
    self.pauseButton.tag = FloatingButton_Pause;
    self.micButton.tag = FloatingButton_Micphone;
    self.cameraButton.tag = FloatingButton_Webcam;
    self.stopButton.tag = FloatingButton_Stop;
    [self.liveButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.micButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(itemsClick:) forControlEvents:UIControlEventTouchUpInside];
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
    [self.liveVM addObserver:self forKeyPath:@"paused" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];}

- (void)bindVM:(ReplayKitLiveViewModel *)liveVM {
    self.liveVM = liveVM;
    [self setupVMObserver];
}

- (NSArray<UIButton *>*)openMenus {
    return @[self.liveButton, self.pauseButton, self.micButton, self.cameraButton, self.stopButton];
}

- (NSArray<UIButton *>*)closeMenus {
    return @[self.liveButton];
}

- (void)setupOpenMenu {
    for (UIView *view in [self closeMenus]) {
        if (view.superview) {
            [view removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setupMenus:[self openMenus]];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.menuOpen = YES;
    }];
}

- (void)setupCloseMenu {
    for (UIView *view in [self openMenus]) {
        if (view.superview) {
            [view removeFromSuperview];
        }
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self setupMenus:[self closeMenus]];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.menuOpen = NO;
    }];
}
- (void)setupMenus:(NSArray<UIView *>*)menus {
    for(int i = 0; i < menus.count; ++ i)
    {
        [menus[i] setFrame: CGRectMake(self.frame.size.width * i++, 0, self.frame.size.width , self.frame.size.width)];
        [self addSubview:menus[i]];
    }
}

@end
