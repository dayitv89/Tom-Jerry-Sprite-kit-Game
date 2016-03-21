//
//  MusicManager.m
//  TestSpriteKit
//
//  Created by Gaurav Sharma on 08/11/15.
//  Copyright © 2015 Punchh Inc. All rights reserved.
//

#import "MusicManager.h"
@import AVFoundation;

@interface MusicManager ()
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@end

@implementation MusicManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (instancetype)init {
    if (self = [super init] ) {
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background-music-aac" withExtension:@"caf"];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
    }
    return self;
}

- (void)playBgMusic {
    [self.backgroundMusicPlayer play];
}

- (void)stopBgMusic {
    [self.backgroundMusicPlayer stop];
}

- (void)pauseBgMusic {
    [self.backgroundMusicPlayer pause];
}

@end
