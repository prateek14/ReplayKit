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
