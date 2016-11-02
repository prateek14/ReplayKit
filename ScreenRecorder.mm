#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>

@interface ScreenRecorder : NSObject<RPScreenRecorderDelegate, RPPreviewViewControllerDelegate> {
}
+ (ScreenRecorder*)Instance;
- (void)Init;
- (BOOL)Start:(BOOL)enableMicrophone;
- (BOOL)Stop;
- (BOOL)Discard;
- (BOOL)Preview;
- (int)GetState;
- (NSString*)GetLastError;
- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder*)screenRecorder;
- (void)screenRecorder:(RPScreenRecorder*)screenRecorder didStopRecordingWithError:(NSError*)error previewViewController:(RPPreviewViewController*)previewViewController;
- (void)previewController:(RPPreviewViewController*)previewController didFinishWithActivityTypes:(NSSet<NSString*>*)activityTypes;
@end

const int STATE_ERROR = -1;
const int STATE_UNINIT = 0;
const int STATE_READY = 1;
const int STATE_RECORDING = 2;
const int STATE_PREVIEWING = 3;
static ScreenRecorder* _instance = nil;

@implementation ScreenRecorder {
    int state;
    RPPreviewViewController* pvc;
    NSString* lastError;
}

- (id)init {
    if(self = [super init]) {
        state = STATE_UNINIT;
        pvc = nil;
        lastError = nil;
    }
    return self;
}

+ (ScreenRecorder*)Instance {
    if(_instance == nil) {
        _instance = [[ScreenRecorder alloc] init];
    }
    return _instance;
}

- (void)Init {
    if([RPScreenRecorder sharedRecorder] != nil && [RPScreenRecorder sharedRecorder].available) {
        [[RPScreenRecorder sharedRecorder] setDelegate:self];
        [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:YES handler:^(NSError* error) {
            if(error == nil) {
                [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController* previewViewController, NSError* error) {
                    state = STATE_READY;
                }];
            }
        }];
    }
}
- (void)screenRecorderDidChangeAvailability:(RPScreenRecorder*)screenRecorder {
}

- (BOOL)Start:(BOOL)enableMicrophone {
    if(state != STATE_READY) return NO;
    if([RPScreenRecorder sharedRecorder] == nil || ![RPScreenRecorder sharedRecorder].available) return NO;
    [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:enableMicrophone handler:^(NSError* error) {
        if(error == nil) {
            state = STATE_RECORDING;
        }
        else {
            state = STATE_ERROR;
            lastError = [error description];
        }
    }];
    return YES;
}
- (void)screenRecorder:(RPScreenRecorder*)screenRecorder didStopRecordingWithError:(NSError*)error previewViewController:(RPPreviewViewController*)previewViewController {
    state = STATE_ERROR;
    if(error != nil) {
        lastError = [error description];
    }
    else {
        lastError = [NSString stringWithUTF8String:"recording stopped"];
    }
}
- (BOOL)Stop {
    if(state != STATE_RECORDING) return NO;
    if([RPScreenRecorder sharedRecorder] == nil || ![RPScreenRecorder sharedRecorder].available) return NO;
    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController* previewViewController, NSError* error) {
        if(error == nil) {
            if(previewViewController != nil) {
                state = STATE_READY;
                pvc = previewViewController;
                [pvc retain];
            }
            else {
                state = STATE_ERROR;
                lastError = [NSString stringWithUTF8String:"invalid preview view controller"];
            }
        }
        else {
            state = STATE_ERROR;
            lastError = [error description];
        }
    }];
    return YES;
}

- (BOOL)Discard {
    if(state != STATE_READY) return NO;
    if([RPScreenRecorder sharedRecorder] == nil || ![RPScreenRecorder sharedRecorder].available) return NO;
    if(pvc == nil) return NO;
    [pvc release];
    pvc = nil;
    [[RPScreenRecorder sharedRecorder] discardRecordingWithHandler:^(){}];
    return YES;
}

- (BOOL)Preview {
    if(state != STATE_READY) return NO;
    if([RPScreenRecorder sharedRecorder] == nil || ![RPScreenRecorder sharedRecorder].available) return NO;
    if(pvc == nil) return NO;
    state = STATE_PREVIEWING;
    [pvc setPreviewControllerDelegate:self];
    [[[UnityGetGLView() window] rootViewController] presentViewController:pvc animated:YES completion:^(){
        [pvc release];
        pvc = nil;
    }];
    return YES;
}
- (void)previewControllerDidFinish:(RPPreviewViewController*)previewController {
    state = STATE_READY;
    if(previewController != nil) {
        [previewController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet<NSString*>*)activityTypes {
}

- (int)GetState {
    return state;
}
- (NSString*)GetLastError {
    return lastError;
}

@end

extern "C" {
    void ScreenRecorderInit() {
        [[ScreenRecorder Instance] Init];
    }
    bool ScreenRecorderStart(BOOL enableMicrophone) {
        return [[ScreenRecorder Instance] Start:enableMicrophone];
    }
    bool ScreenRecorderStop() {
        return [[ScreenRecorder Instance] Stop];
    }
    bool ScreenRecorderDiscard() {
        return [[ScreenRecorder Instance] Discard];
    }
    bool ScreenRecorderPreview() {
        return [[ScreenRecorder Instance] Preview];
    }
    int ScreenRecorderGetState() {
        return [[ScreenRecorder Instance] GetState];
    }
    const char* ScreenRecorderGetLastError() {
        NSString* str = [[ScreenRecorder Instance] GetLastError];
        if(str == nil) return NULL;
        const char* error = [str cStringUsingEncoding:NSUTF8StringEncoding];
        if(error != NULL) error = strdup(error);
        return error;
    }
}
