//
//  ViewController.m
//  VideoCropper
//
//  Created by deepaks on 24/08/16.
//  Copyright © 2016 deepaks. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
@interface ViewController ()
{
    AVPlayerViewController *playerViewController;
    AVPlayerItem* item;
    UIButton *Play;
    BOOL isPlay;
    UIActivityIndicatorView *loading;
    UIImageView*maskView;
    CGSize _imageSize;
    CGFloat videoPlayerScale;
    
}

@end

@implementation ViewController
@synthesize VideoURL,ScrollOverlay;

- (void)viewDidLoad {
    VideoURL=[NSURL URLWithString:@"https://video.xx.fbcdn.net/v/t43.1792-2/13685706_1796342757276157_418386533_n.mp4?efg=eyJybHIiOjE1MDAsInJsYSI6MTAyNCwidmVuY29kZV90YWciOiJzdmVfaGQifQ%3D%3D&rl=1500&vabr=600&oh=1f2d2cea2bd15dd9abd3118326af8778&oe=57C01446"];
    [self PlayVideo:VideoURL];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)PlayVideo:(NSURL *)URL
{
    playerViewController= [[AVPlayerViewController alloc]init];
    item=[[AVPlayerItem alloc]initWithURL:URL];
    self.videoAsset=[AVAsset assetWithURL:URL];
    [playerViewController setVideoGravity:AVLayerVideoGravityResizeAspect];
    playerViewController.player=[AVPlayer playerWithPlayerItem:item];
    playerViewController.showsPlaybackControls=NO;
    CGSize size = [[[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    self.videoPlaybackPosition=0;
    CGSize Cropsize;
    if (size.height > size.width) {
        Cropsize.width = self.view.frame.size.width;
        Cropsize.height = (Cropsize.width / size.width) * self.view.frame.size.height-45;
        videoPlayerScale =  Cropsize.width / size.width;
        playerViewController.view.frame =CGRectMake(0, 0, Cropsize.width, Cropsize.height);
        
        
    } else {
        Cropsize.height = self.view.frame.size.height-45;
        Cropsize.width = (Cropsize.height / size.height) * size.width;
        videoPlayerScale =  Cropsize.height / size.height;
        playerViewController.view.frame =CGRectMake(0, 0, Cropsize.width, Cropsize.height);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    maskView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-45)];
    maskView.image = [UIImage imageNamed:@"Grid"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ScrollOverlay addSubview:playerViewController.view];
        [playerViewController.player play];
        
    });
    [self configureForImageSize:playerViewController.view.frame.size];
    UIPanGestureRecognizer *cropViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cropViewPanGestureAction:)];
    [self.view addGestureRecognizer:cropViewPanGesture];
    
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark Crop Methods
- (void)cropViewPanGestureAction:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [maskView removeFromSuperview];
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            [self.view insertSubview:maskView aboveSubview:playerViewController.view];
            break;
        }
        default:
            break;
    }
}

- (void)configureForImageSize:(CGSize)VideoSize
{
    _imageSize = VideoSize;
    ScrollOverlay.contentSize = VideoSize;
    if (VideoSize.width > VideoSize.height) {
        ScrollOverlay.contentOffset = CGPointMake(VideoSize.width/4, 0);
    } else if (VideoSize.width < VideoSize.height) {
        ScrollOverlay.contentOffset = CGPointMake(0, VideoSize.height/4);
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    ScrollOverlay.zoomScale = ScrollOverlay.minimumZoomScale;
}
- (void)setMaxMinZoomScalesForCurrentBounds
{
    ScrollOverlay.minimumZoomScale = 1.0;
    ScrollOverlay.maximumZoomScale = 2.0;
}

- (CGRect) rangeRestrictForRect:(CGRect )unitRect
{
    //incase <0 or >1
    if(unitRect.origin.x < 0) unitRect.origin.x = 0;
    if(unitRect.origin.x > 1) unitRect.origin.x = 1;
    if(unitRect.origin.y < 0) unitRect.origin.y = 0;
    if(unitRect.origin.y > 1) unitRect.origin.y = 1;
    if(unitRect.size.height < 0) unitRect.size.height = 0;
    if(unitRect.size.height > 1) unitRect.size.height = 1;
    if(unitRect.size.width < 0) unitRect.size.width = 0;
    if(unitRect.size.width > 1) unitRect.size.width = 1;
    
    return unitRect;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnActionNext:(id)sender {
    loading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loading.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
    [self.view addSubview:loading];
    [loading startAnimating];
    [_btnNext setUserInteractionEnabled:NO];
    self.videoPlaybackPosition=0;
    [playerViewController.player pause];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.videoAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *videoTrack= [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration)
                            ofTrack:[[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                             atTime:kCMTimeZero error:nil];
        if ([[self.videoAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
        {
            AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration)
                                           ofTrack:[[self.videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                            atTime:kCMTimeZero error:nil];
        }
        BOOL isVideoAssetPortrait_=NO;
        AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
        AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        CGRect visibleRect = [ScrollOverlay convertRect:ScrollOverlay.bounds toView:playerViewController.view];
        UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
        CGAffineTransform t = CGAffineTransformMakeScale( 1 / videoPlayerScale, 1 / videoPlayerScale);
        visibleRect = CGRectApplyAffineTransform(visibleRect, t);
        CGFloat cropOffX = visibleRect.origin.x;
        CGFloat cropOffY = visibleRect.origin.y;
        CGFloat cropWidth = 0.0 ;
        CGFloat cropHeight = 0.0 ;
        CGAffineTransform t1 = CGAffineTransformIdentity;
        CGAffineTransform t2 = CGAffineTransformIdentity;
        
        AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
            videoAssetOrientation_ = UIImageOrientationRight;
            isVideoAssetPortrait_ = YES;
        }
        if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
            videoAssetOrientation_ =  UIImageOrientationLeft;
            isVideoAssetPortrait_ = YES;
        }
        if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
            isVideoAssetPortrait_  = NO;
            t1 = CGAffineTransformMakeTranslation(0 - cropOffX, 0 - cropOffY );
            t2 = CGAffineTransformRotate(t1, 0 );
            
            
        }
        if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
            isVideoAssetPortrait_  = NO;
            videoAssetOrientation_ = UIImageOrientationDown;
        }
        CGSize naturalSize;
        if(isVideoAssetPortrait_){
            naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
            [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
        } else {
            cropWidth = visibleRect.size.width;
            cropHeight = visibleRect.size.height;
            CGAffineTransform finalTransform = t2;
            [videolayerInstruction setTransform:finalTransform atTime:kCMTimeZero];
        }
        
        
        
        [videolayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
        
        
        mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
        AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
        
        if(isVideoAssetPortrait_){
            mainCompositionInst.renderSize = CGSizeMake(naturalSize.width, naturalSize.height);
        } else {
            mainCompositionInst.renderSize = CGSizeMake(cropWidth, cropHeight);
        }
        
        mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
        mainCompositionInst.frameDuration = CMTimeMake(1, 30);
        CMTime start = CMTimeMakeWithSeconds(self.startTime,mixComposition.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, mixComposition.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        
        self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset1920x1080];
        self.exportSession.outputURL = [self uniqueURL];
        VideoURL=self.exportSession.outputURL ;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        self.exportSession.timeRange = range;
        self.exportSession.videoComposition = mainCompositionInst;
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                switch ([self.exportSession status]) {
                    case AVAssetExportSessionStatusFailed:
                        
                        NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        
                        NSLog(@"Export canceled");
                        break;
                    default:
                        NSLog(@"NONE");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.view setUserInteractionEnabled:NO];
                            [self performSegueWithIdentifier:@"Player" sender:self];
                        });
                        
                        break;
                }
            });
        }];
        
    }
}
- (NSURL *)uniqueURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
    NSURL *fileURL = [NSURL fileURLWithPath:myPathDocs];
    return fileURL;
}
-(void)itemDidFinishPlaying
{
    int32_t timeScale = playerViewController.player.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(0, timeScale);
    [playerViewController.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [playerViewController.player play];
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        [loading stopAnimating];
        PlayerViewController*PlayerVC;
        PlayerVC=segue.destinationViewController;
        PlayerVC.VideoURL=VideoURL;
        NSLog(@"URLLLLLL===%@",VideoURL);

}

@end
