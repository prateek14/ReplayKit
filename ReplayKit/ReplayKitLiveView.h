//
//  RPLiveCtrlView.h
//  Fox
//
//  Created by jinchu darwin on 12/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplayKitLiveViewModel.h"

typedef enum
{
    FloatingButton_Live = 0,
    FloatingButton_Pause = FloatingButton_Live + 1,
    FloatingButton_Micphone = FloatingButton_Live + 2,
    FloatingButton_Webcam = FloatingButton_Live + 3,
    FloatingButton_Stop = FloatingButton_Live + 4,
} FloatingButtonIndex;

typedef enum : NSUInteger {
    RPMenuLeftDirection,
    RPMenuRightDirection,
    RPMenuUpDirection,
    RPMenuDownDirection,
} RPMenuDirection;

@interface ReplayKitLiveView : UIView

- (void)bindVM:(ReplayKitLiveViewModel *)liveVM;

@end
