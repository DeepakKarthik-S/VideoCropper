//
//  PlayerViewController.m
//  VideoCropper
//
//  Created by deepaks on 24/08/16.
//  Copyright © 2016 deepaks. All rights reserved.
//

#import "PlayerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface PlayerViewController ()
{
    AVPlayerViewController*playerViewController;
}
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    playerViewController= [[AVPlayerViewController alloc]init];
    playerViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+45, self.view.frame.size.width, self.view.frame.size.height-90);
    AVPlayerItem*item=[[AVPlayerItem alloc]initWithURL:self.VideoURL];
    self.videoAsset=[AVAsset assetWithURL:self.VideoURL];
    [self.view addSubview:playerViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    [playerViewController setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    playerViewController.player=[AVPlayer playerWithPlayerItem:item];
    [playerViewController.player play];
    playerViewController.showsPlaybackControls=NO;

    // Do any additional setup after loading the view.
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)itemDidFinishPlaying
{
    int32_t timeScale = playerViewController.player.currentItem.asset.duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(0, timeScale);
    [playerViewController.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [playerViewController.player play];
}

- (IBAction)btnActionSave:(id)sender {
    ALAssetsLibrary *library=[[ALAssetsLibrary alloc]init];
    [library writeVideoAtPathToSavedPhotosAlbum:self.VideoURL completionBlock:^(NSURL *assetURL, NSError *error){
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
