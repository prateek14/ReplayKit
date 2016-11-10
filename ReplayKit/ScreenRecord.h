#import "ReplayKit/ReplayKit.h"

@interface ScreenRecord : NSObject<RPScreenRecorderDelegate, RPPreviewViewControllerDelegate>

+ (ScreenRecord*)Instance;
- (void)startRecording;
- (void)stopRecording;
- (void)discardRecording;
- (BOOL)isRecording;

- (BOOL)canPreview;
- (void)preview;

- (void)screenRecorder:(nonnull RPScreenRecorder*)screenRecorder didStopRecordingWithError:(nonnull NSError*)error previewViewController:(nullable RPPreviewViewController*)previewViewController;

- (void)previewControllerDidFinish:(nonnull RPPreviewViewController*)previewController;

@end

