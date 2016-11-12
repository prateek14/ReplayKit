#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>
#import "ScreenRecord.h"
#import "ReplayKitLiveView.h"
#import "ReplayKitLiveViewModel.h"
#include "UnityForwardDecls.h"

// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
    if (string)
        return [NSString stringWithUTF8String: string];
    else
        return nil;
}

// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

static ScreenRecord* _instance;


@implementation ScreenRecord
{
    RPPreviewViewController* _previewController;
}

+ (nullable instancetype)Instance
{
    if (_instance == nil)
    {
        _instance = [[ScreenRecord alloc] init];
    }
    return _instance;
}

- (void)sendMessage:(nonnull NSString*)methodName msg:(nullable NSString*)msg
{
    if (methodName == nil)
    {
        return;
    }
    if (msg == nil)
    {
        msg = @"";
    }
    UnitySendMessage(MakeStringCopy([@"Game" UTF8String]),
                     MakeStringCopy([methodName UTF8String]),
                     MakeStringCopy([msg UTF8String]));
}

- (void)startRecording
{
    if([self isRecording])
    {
        return;
    }
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        [self sendMessage:@"ScreenRecord_StartRecordingComplete" msg:@"Failed to get Screen Recorder"];
        return;
    }
    [recorder setDelegate:self];
    [recorder startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
        
        if ([NSThread isMainThread])
        {
            if (error == nil)
            {
                NSLog(@"ScreenRecord_StartRecordingComplete1");
                [self sendMessage:@"ScreenRecord_StartRecordingComplete" msg:nil];
                return;
            }
            else
            {
                NSLog(@"ScreenRecord_StartRecordingComplete2");
                [self sendMessage:@"ScreenRecord_StartRecordingComplete" msg:[error description]];
            }
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                //Update UI in UI thread here
                if (error == nil)
                {
                    NSLog(@"ScreenRecord_StartRecordingComplete1");
                    [self sendMessage:@"ScreenRecord_StartRecordingComplete" msg:nil];
                    return;
                }
                else
                {
                    NSLog(@"ScreenRecord_StartRecordingComplete2");
                    [self sendMessage:@"ScreenRecord_StartRecordingComplete" msg:[error description]];
                }
            });
        }
    }];
    NSLog(@"startRecording done");
}

- (void)stopRecording
{
    if(![self isRecording])
    {
        return;
    }
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        [self sendMessage:@"ScreenRecorder_StopRecordingComplete" msg:@"Failed to get Screen Recorder"];
        return;
    }
    [recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        if ([NSThread isMainThread])
        {
            if (error != nil)
            {
                NSLog(@"ScreenRecorder_StopRecordingComplete1");
                [self sendMessage:@"ScreenRecorder_StopRecordingComplete" msg:[error description]];
                return;
            }
            if (previewViewController != nil)
            {
                [previewViewController setPreviewControllerDelegate:self];
                _previewController = previewViewController;
            }
            NSLog(@"ScreenRecorder_StopRecordingComplete2");
            [self sendMessage:@"ScreenRecorder_StopRecordingComplete" msg:nil];
            [self preview];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                //Update UI in UI thread here
                if (error != nil)
                {
                    NSLog(@"ScreenRecorder_StopRecordingComplete1");
                    [self sendMessage:@"ScreenRecorder_StopRecordingComplete" msg:[error description]];
                    return;
                }
                if (previewViewController != nil)
                {
                    [previewViewController setPreviewControllerDelegate:self];
                    _previewController = previewViewController;
                }
                NSLog(@"ScreenRecorder_StopRecordingComplete2");
                [self sendMessage:@"ScreenRecorder_StopRecordingComplete" msg:nil];
                [self preview];
                
            });
        }
    }];
    
    NSLog(@"stopRecording done");
}

- (void)discardRecording
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        [self sendMessage:@"ScreenRecorder_DiscardRecordingComplete" msg:@"Failed to get Screen Recorder"];
        return;
    }
    
    [recorder discardRecordingWithHandler:^{
        _previewController = nil;
        [self sendMessage:@"ScreenRecorder_DiscardRecordingComplete" msg:nil];
    }];
    
    NSLog(@"discardRecording done");
}


- (BOOL)isRecording
{
    RPScreenRecorder* recorder = [RPScreenRecorder sharedRecorder];
    if (recorder == nil)
    {
        return NO;
    }
    return [recorder isRecording];
}

- (BOOL)canPreview
{
    return _previewController != nil;
}

- (void)preview
{
    if (![self canPreview])
    {
        return;
    }
    //[_previewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [[[UnityGetGLView() window] rootViewController] presentViewController:_previewController animated:YES completion:^()
    {
        NSLog(@"presentViewController _previewController!!!");
        //_previewController = nil;
    }];
}

- (void)screenRecorder:(nonnull RPScreenRecorder*)screenRecorder didStopRecordingWithError:(nonnull NSError*)error previewViewController:(nullable RPPreviewViewController*)previewViewController
{
    NSLog(@"didStopRecordingWithError:%@-%@", _previewController, previewViewController);
    NSLog(@"didStopRecordingWithError:%@", error);
    _previewController = previewViewController;
    [self sendMessage:@"ScreenRecorder_DidStopRecordingWithError" msg:[error description]];
}

- (void)previewControllerDidFinish:(nonnull RPPreviewViewController*)previewController
{
    NSLog(@"previewControllerDidFinish:%@", previewController);
    [previewController dismissViewControllerAnimated:YES completion:nil];
    [self sendMessage:@"ScreenRecorder_PreviewControllerDidFinish" msg:nil];
}

@end



//-----

extern "C"
{
    void screenRecord_startRecord()
    {
        [[ScreenRecord Instance] startRecording];
    }
    void screenRecord_stopRecord()
    {
        [[ScreenRecord Instance] stopRecording];
    }
    void screenRecord_discardRecording()
    {
        [[ScreenRecord Instance] discardRecording];
    }
    
    bool screenRecord_isRecording()
    {
        return [[ScreenRecord Instance] isRecording] == YES;
    }
    bool screenRecord_CanPreview()
    {
        return [[ScreenRecord Instance] canPreview] == YES;
    }
    void screenRecord_Preview()
    {
        [[ScreenRecord Instance] preview];
    }
}
