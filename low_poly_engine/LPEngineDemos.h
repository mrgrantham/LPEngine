//
//  EngineDemos.h
//  low_poly_engine
//
//  Created by James Granthamon 8/18/17.
//  Copyright © 2017 James Grantham All rights reserved.
//

#ifndef EngineDemos_h
#define EngineDemos_h

#import "LPEngineModel.h"
#import "LPEngineScene.h"

@interface LPEngineDemos : NSObject

@property (nonatomic, strong) LPEngineScene* demoScene;
@property (nonatomic, assign) BOOL rotateContinuous;
@property (nonatomic, assign) BOOL translateContinuous;
@property (nonatomic, assign) BOOL scaleContinuous;
@property (nonatomic, assign) BOOL flyContinuous;
//@property (nonatomic, assign) LPPoint flightRotation;
//@property (nonatomic, assign) LPPoint flightTranslation;
//@property (nonatomic, assign) LPPoint flightScaling;
@property (nonatomic, assign) LPPoint rotationRadians;
@property (nonatomic, assign) LPPoint translationRadians;
@property (nonatomic, assign) LPPoint scaleRadians;
@property (nonatomic, assign) NSInteger arwingID;

+ (id)sharedManager;
- (id) init;
- (void) triangleDemo;
- (void) arwingDemo;
- (void)applyRotation:(LPPoint)rotation;
- (void) resetArwing;
- (void) resetFlight;

@end

#endif /* EngineDemos_h */
