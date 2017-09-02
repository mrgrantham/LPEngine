//
//  EngineDemos.h
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef EngineDemos_h
#define EngineDemos_h

#import "LPEngineModel.h"

@interface EngineDemos : NSObject

@property (nonatomic, strong) LPEngineModel* arwing;
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


+ (id)sharedManager;
- (id) init;
- (void) triangleDemo;
- (void) arwingDemo;
- (void) resetArwing;
- (void) resetFlight;

@end

#endif /* EngineDemos_h */
