//
//  GameOverScene.m
//  TestSpriteKit
//
//  Created by Gaurav Sharma on 08/11/15.
//  Copyright © 2015 Punchh Inc. All rights reserved.
//

#import "GameOverScene.h"
#import "MusicManager.h"

@interface GameOverScene ()
@property (nonatomic) GameScene *backScreen;
@end

@implementation GameOverScene

-(id)initWithSize:(CGSize)size won:(BOOL)won andScene:(GameScene *)scene {
    if (self = [super initWithSize:size]) {
        self.backScreen = scene;
        [[MusicManager sharedInstance] pauseBgMusic];
        
        self.backgroundColor = [SKColor colorWithRed:49.0 green:113.0 blue:190.0 alpha:1.0];
        
        SKSpriteNode *bgImg = [SKSpriteNode spriteNodeWithImageNamed:won?@"game_new_bg3":@"game_bg_new2"];
        bgImg.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:bgImg];
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = won?@"You Won!":@"You Lose :[";
        label.fontSize = 40;
        label.fontColor = [SKColor whiteColor];
        label.position = CGPointMake(self.size.width/2 + 70, self.size.height/2 + 60);
        [self addChild:label];
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view presentScene:self.backScreen];
    [self.backScreen startAgain];
}

@end
