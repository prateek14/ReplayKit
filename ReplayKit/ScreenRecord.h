#import "ReplayKit/ReplayKit.h"

@interface ScreenRecord : NSObject<RPScreenRecorderDelegate, RPPreviewViewControllerDelegate>

+ (nullable instancetype)Instance;
- (void)startRecording;
- (void)stopRecording;
- (void)discardRecording;
- (BOOL)isRecording;

- (BOOL)canPreview;
- (void)preview;

- (void)screenRecorder:(nonnull RPScreenRecorder*)screenRecorder didStopRecordingWithError:(nonnull NSError*)error previewViewController:(nullable RPPreviewViewController*)previewViewController;

- (void)previewControllerDidFinish:(nonnull RPPreviewViewController*)previewController;

@end

