//
//  GameOverScene.h
//  TestSpriteKit
//
//  Created by Gaurav Sharma on 08/11/15.
//  Copyright © 2015 Punchh Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface GameOverScene : SKScene
-(id)initWithSize:(CGSize)size won:(BOOL)won andScene:(GameScene*)scene;
@end
