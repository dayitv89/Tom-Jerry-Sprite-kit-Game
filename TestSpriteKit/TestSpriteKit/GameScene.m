//
//  GameScene.m
//  TestSpriteKit
//
//  Created by Gaurav Sharma on 08/11/15.
//  Copyright (c) 2015 Punchh Inc. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "MusicManager.h"

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;

@interface GameScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int monstersDestroyed;
@property (nonatomic) int monsterRequired;
@property (nonatomic) int shotsFireRemain;
@property (nonatomic) SKLabelNode *lblLevel, *lblMonstersList, *lblShots;
@property (nonatomic) int level;
@end

@implementation GameScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self addPlayerNow];
        self.level = 1;
        
        if (DEBUG_GAME) {
            self.monsterRequired = 1;
        }
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        [self setLabelLevel];
    }
    return self;
}

- (void)addPlayerNow {
    SKSpriteNode *bgImg = [SKSpriteNode spriteNodeWithImageNamed:@"game_bg_new"];
    bgImg.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:bgImg];
    
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"jerry1"];
    self.player.position = CGPointMake(100, 100);
    [self addChild:self.player];
    
    SKTextureAtlas * atlas = [SKTextureAtlas atlasNamed:@"jerry"];
    SKTexture * runTexture1 = [atlas textureNamed:@"jerry1.png"];
    SKTexture * runTexture2 = [atlas textureNamed:@"jerry2.png"];
    SKTexture * runTexture3 = [atlas textureNamed:@"jerry3.png"];
    NSArray * runTexture = @[runTexture1, runTexture2, runTexture3, runTexture2];
    [self.player runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:runTexture timePerFrame:2.]]];
}

- (void)setLabelLevel {
    self.lblLevel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.lblLevel.text = [NSString stringWithFormat:@"Level %d", self.level];
    self.lblLevel.fontSize = 40;
    self.lblLevel.fontColor = [SKColor blackColor];
    self.lblLevel.position = CGPointMake(self.size.width/2, self.size.height - 35);
    [self addChild:self.lblLevel];
    
    if (DEBUG_GAME) {
        self.monsterRequired = 1;
    } else {
        self.monsterRequired = LEVEL_1_MIN_MONSTOR + ((self.level-1)*LEVEL_MONSTERS_ADD);
    }
    
    [self setLabelMonsters];
    [self setShotsFireOnLevel];
}

- (void)setLabelMonsters {
    self.lblLevel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.lblLevel.fontSize = 15;
    self.lblLevel.fontColor = [SKColor whiteColor];
    self.lblLevel.position = CGPointMake(self.size.width - 80, 20);
    [self addChild:self.lblLevel];
    [self refreshScore];
}

- (void)refreshScore {
    self.lblLevel.text = [NSString stringWithFormat:@"Tom Killed %d/%d", self.monstersDestroyed, self.monsterRequired];
}

- (void)setShotsFireOnLevel {
    self.lblShots = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.lblShots.fontSize = 15;
    self.lblShots.fontColor = [SKColor whiteColor];
    self.lblShots.position = CGPointMake(90, 20);
    [self addChild:self.lblShots];
    self.shotsFireRemain = LEVEL_SHOTS_REMAIN + ((self.level - 1) * LEVEL_SHOTS_ADD);
    [self refreshShots];
}

- (void)refreshShots {
    self.lblShots.text = [NSString stringWithFormat:@"%d shots remain", self.shotsFireRemain];
}

- (void)addMonster {
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    // Determine where to spawn the monster along the Y axis
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    double minDuration, maxDuration;
    if (DEBUG_GAME) {
        minDuration = LEVEL_1_MIN_SPEED;
        maxDuration = LEVEL_1_MAX_SPEED;
    } else {
        minDuration = LEVEL_1_MIN_SPEED - ((self.level-1)*LEVEL_SPEEDUP_FECTOR);
        maxDuration = LEVEL_1_MAX_SPEED - ((self.level-1)*LEVEL_SPEEDUP_FECTOR);
        
        minDuration = minDuration <= 0.0 ? 0.5 : minDuration;
        maxDuration = maxDuration <= 1.0 ? 1.5 : maxDuration;
    }
    double rangeDuration = maxDuration - minDuration;
    double actualDuration = fmod(arc4random(), rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO andScene:self];
        [self.view presentScene:gameOverScene transition: reveal];
    }];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone, loseAction]]];
    
    monster.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:monster.size.width/2];
    monster.physicsBody.dynamic = YES; // 2
    monster.physicsBody.categoryBitMask = monsterCategory; // 3
    monster.physicsBody.contactTestBitMask = projectileCategory; // 4
    monster.physicsBody.collisionBitMask = 0; // 5
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.shotsFireRemain <= 0) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO andScene:self];
        [self.view presentScene:gameOverScene transition: reveal];
    }
    
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2 - Set up initial location of projectile
    SKSpriteNode * projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.player.position;
    
    // 3- Determine offset of location to projectile
    CGPoint offset = rwSub(location, projectile.position);
    
    // 4 - Bail out if you are shooting down or backwards
//    if (offset.x <= 0) return;
    
    // 5 - OK to add now - we've double checked position
    [self addChild:projectile];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    
    // 9 - Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    // add some sound
    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    
    // decrese shots count
    self.shotsFireRemain--;
    [self refreshShots];
}


- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster {
    [projectile removeFromParent];
    [monster removeFromParent];
    // add some sound
    [self runAction:[SKAction playSoundFileNamed:@"StarPing.wav" waitForCompletion:NO]];
    
    self.monstersDestroyed++;
    [self refreshScore];
    
    // You won
    if (self.monstersDestroyed >= self.monsterRequired) {
        self.level++;
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES andScene:self];
        [self.view presentScene:gameOverScene transition: reveal];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *)firstBody.node didCollideWithMonster:(SKSpriteNode *)secondBody.node];
    }
}

- (void)startAgain {
    [[MusicManager sharedInstance] playBgMusic];
    [self removeAllChildren];
    self.monstersDestroyed = 0;
    [self addPlayerNow];
    [self setLabelLevel];
}

@end
