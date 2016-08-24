//
//  TrimmerViewController.m
//  VideoCropper
//
//  Created by deepaks on 24/08/16.
//  Copyright © 2016 deepaks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface PlayerViewController : UIViewController
@property(strong, nonatomic) NSURL *VideoURL;
@property(strong, nonatomic) AVAsset *videoAsset;

@end
