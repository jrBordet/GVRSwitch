#import <UIKit/UIKit.h>

#import "VideoPlayerViewController.h"

#import "GVRVideoView.h"

@interface VideoPlayerViewController () <GVRVideoViewDelegate>
@property(nonatomic) IBOutlet GVRVideoView *videoView;
@property(nonatomic) IBOutlet UITextView *attributionTextView;
- (IBAction)switchItem:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation VideoPlayerViewController {
    BOOL _isPaused;
    NSUInteger index;
    NSArray *url;
}

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    
    index = 0;
    
    return self;
}

/*
 url = [NSArray arrayWithObjects:
 @"http://360clips.s3-eu-west-1.amazonaws.com/zencoder/output5/playlist.m3u8",
 @"https://360clips.s3-eu-west-1.amazonaws.com/EURO/Germania+-+Italia/M47_GER-ITA_BONUCCI+GOAL_360.mp4",
 @"https://360clips.s3-eu-west-1.amazonaws.com/EURO/Stereo+clips/2017887-Goal_Daniel_Sturridge_360_TB.mp4",
 @"http://360clips.s3-eu-west-1.amazonaws.com/EURO/Germania+-+Italia/M47_GER-ITA_BONUCCI+GOAL_360.mp4",
 @"http://vod-i.ngs.deltatre.net/56e64950-63fe-4ccb-ada3-d3e3e2c1ef52/32d08cdd-1782-46f7-859d-63f6db4ffa49.ism/manifest(format=m3u8-aapl-v3)",
 @"http://dmvideo.deltatre.it/VR/TEST_MBR_overlaysH264/main.m3u8", nil];
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    url = [NSArray arrayWithObjects:
           @"https://360clips.s3-eu-west-1.amazonaws.com/EURO/Stereo+clips/2017887-Goal_Daniel_Sturridge_360_TB.mp4",
           @"https://360clips.s3-eu-west-1.amazonaws.com/EURO/Germania+-+Italia/M47_GER-ITA_BONUCCI+GOAL_360.mp4",
           @"http://video360.ngdp.deltatre.net/360_transc_dgkv34jbwiufbu534jbkhb/smil:matchA_12_MBR.smil/playlist.m3u8",
           @"http://54.228.204.57:1935/360_transc_dgkv34jbwiufbu534jbkhb/smil:matchA_12_MBR.smil/playlist.m3u8",
           @"http://ch01-digitalmpillarmsnelab.streaming.mediaservices.windows.net/0723c5b7-cb81-47d4-9a55-69161d7f6207/cb2e80ad-1cf7-4955-a8a5-c27b19fe3437.ism/manifest(format=m3u8-aapl-v3)", nil];
    
    NSURL *videoURL = [NSURL URLWithString:[url objectAtIndex:index]];

    // Build source attribution text view.
    NSString *sourceText =[videoURL absoluteString];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]
                                                 initWithString:sourceText];
    [attributedText
     addAttribute:NSLinkAttributeName
     value:@"https://en.wikipedia.org/wiki/Gorilla"
     range:NSMakeRange(sourceText.length, attributedText.length - sourceText.length)];
    
    _attributionTextView.attributedText = attributedText;
    
    _videoView.delegate = self;
    _videoView.enableFullscreenButton = YES;
    _videoView.enableCardboardButton = YES;
    _videoView.enableTouchTracking = YES;
    
    _isPaused = YES;
    
    // Load the sample 360 video, which is of type stereo-over-under.
    //  NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"congo" ofType:@"mp4"];
    //  [_videoView loadFromUrl:[[NSURL alloc] initFileURLWithPath:videoPath]
    //                   ofType:kGVRVideoTypeStereoOverUnder];
    

    // Alternatively, this is how to load a video from a URL:
    [_videoView loadFromUrl:videoURL ofType:kGVRVideoTypeStereoOverUnder];
    
    // [NSURL URLWithString:@"https://raw.githubusercontent.com/googlevr/gvr-ios-sdk"
    // @"/master/Samples/VideoWidgetDemo/resources/congo.mp4"]
}

#pragma mark - GVRVideoViewDelegate

- (void)widgetViewDidTap:(GVRWidgetView *)widgetView {
    if (_isPaused) {
        [_videoView play];
    } else {
        [_videoView pause];
    }
    _isPaused = !_isPaused;
}

- (void)widgetView:(GVRWidgetView *)widgetView didLoadContent:(id)content {
    NSLog(@"Finished loading video");
    [_videoView play];
    _isPaused = NO;
    self.messageLabel.text = @"Finished loading video";
}

- (void)widgetView:(GVRWidgetView *)widgetView
didFailToLoadContent:(id)content
  withErrorMessage:(NSString *)errorMessage {
    NSLog(@"Failed to load video: %@", errorMessage);
    self.messageLabel.text = [NSString stringWithFormat:@"Failed to load video: %@", errorMessage];;
}

- (void)videoView:(GVRVideoView*)videoView didUpdatePosition:(NSTimeInterval)position {
    // Loop the video when it reaches the end.
    if (position == videoView.duration) {
        [_videoView seekTo:0];
        [_videoView play];
    }
}

- (IBAction)switchItem:(UIBarButtonItem *)sender {
    index++;
    
    index == url.count ? index = 0 : index;
    
    NSURL *videoURL = [NSURL URLWithString:[url objectAtIndex:index]];
    [_videoView loadFromUrl:videoURL ofType:kGVRVideoTypeStereoOverUnder];
    
    NSLog(@"Load video: %@", [videoURL absoluteString]);
    
    NSString *sourceText =[videoURL absoluteString];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]
                                                 initWithString:sourceText];
    [attributedText
     addAttribute:NSLinkAttributeName
     value:@"https://en.wikipedia.org/wiki/Gorilla"
     range:NSMakeRange(sourceText.length, attributedText.length - sourceText.length)];
    
    _attributionTextView.attributedText = attributedText;
}
@end
