//
//  MusicManager.h
//  TestSpriteKit
//
//  Created by Gaurav Sharma on 08/11/15.
//  Copyright © 2015 Punchh Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicManager : NSObject

+ (instancetype)sharedInstance;
- (void)playBgMusic;
- (void)stopBgMusic;
- (void)pauseBgMusic;

@end
