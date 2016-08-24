//
//  ViewController.h
//  VideoCropper
//
//  Created by deepaks on 24/08/16.
//  Copyright © 2016 deepaks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;
@property(strong, nonatomic) AVAsset *videoAsset;
@property(strong, nonatomic) NSURL *VideoURL;
@property (strong, nonatomic) NSString *tempVideoPath;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollOverlay;
@property (strong, nonatomic) NSString *StringID;

@end

