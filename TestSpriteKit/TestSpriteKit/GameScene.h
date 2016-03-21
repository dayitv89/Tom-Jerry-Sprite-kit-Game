//
//  GameScene.h
//  TestSpriteKit
//

//  Copyright (c) 2015 Punchh Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#ifndef DEBUG_GAME 
    #define DEBUG_GAME NO
#endif

#ifndef LEVEL_1_MIN_MONSTOR
    #define LEVEL_1_MIN_MONSTOR 20
#endif

#ifndef LEVEL_MONSTERS_ADD
    #define LEVEL_MONSTERS_ADD 5
#endif

#ifndef LEVEL_1_MIN_SPEED
    #define LEVEL_1_MIN_SPEED 2
#endif

#ifndef LEVEL_1_MAX_SPEED
    #define LEVEL_1_MAX_SPEED 4
#endif

#ifndef LEVEL_SPEEDUP_FECTOR
    #define LEVEL_SPEEDUP_FECTOR 0.5
#endif

#ifndef LEVEL_SHOTS_REMAIN
    #define LEVEL_SHOTS_REMAIN 30
#endif

#ifndef LEVEL_SHOTS_ADD
    #define LEVEL_SHOTS_ADD 8
#endif

@interface GameScene : SKScene
- (void)startAgain;
@end
